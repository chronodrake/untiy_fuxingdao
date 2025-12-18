using UnityEditor;
using UnityEngine;
using System.Collections.Generic;

public class BatchCombineMeshes : EditorWindow
{
    [MenuItem("GameObject/合并子物体为单个模型")]
    static void CombineSelectedParent()
    {
        // 确保只选中1个父物体
        if (Selection.gameObjects.Length != 1)
        {
            EditorUtility.DisplayDialog("提示", "请仅选中需要合并的父物体！", "确定");
            return;
        }

        GameObject parent = Selection.gameObjects[0];
        // 收集所有子物体的MeshFilter和MeshRenderer
        MeshFilter[] allMeshFilters = parent.GetComponentsInChildren<MeshFilter>();
        MeshRenderer[] allMeshRenderers = parent.GetComponentsInChildren<MeshRenderer>();

        if (allMeshFilters.Length == 0)
        {
            EditorUtility.DisplayDialog("提示", "父物体下没有带Mesh的子物体！", "确定");
            return;
        }

        // 1. 收集合并所需的网格和材质
        List<CombineInstance> combineInstances = new List<CombineInstance>();
        List<Material> allMaterials = new List<Material>();

        foreach (MeshFilter filter in allMeshFilters)
        {
            // 获取子物体相对于父物体的本地变换（保证合并后位置正确）
            CombineInstance ci = new CombineInstance();
            ci.mesh = filter.sharedMesh;
            ci.transform = filter.transform.localToWorldMatrix; // 转换为世界空间（或用localMatrix，看需求）
            combineInstances.Add(ci);

            // 收集材质（去重）
            MeshRenderer renderer = filter.GetComponent<MeshRenderer>();
            if (renderer != null)
            {
                foreach (Material mat in renderer.sharedMaterials)
                {
                    if (!allMaterials.Contains(mat))
                    {
                        allMaterials.Add(mat);
                    }
                }
            }
        }

        // 2. 创建新的合并后物体
        GameObject combinedObj = new GameObject(parent.name + "_合并后");
        combinedObj.transform.position = parent.transform.position;
        combinedObj.transform.rotation = parent.transform.rotation;
        combinedObj.transform.localScale = parent.transform.localScale;

        // 3. 赋值合并后的网格和材质
        MeshFilter combinedFilter = combinedObj.AddComponent<MeshFilter>();
        MeshRenderer combinedRenderer = combinedObj.AddComponent<MeshRenderer>();

        combinedFilter.mesh = new Mesh();
        combinedFilter.mesh.CombineMeshes(combineInstances.ToArray(), true, true); // 合并网格（合并子网格、使用世界变换）
        combinedRenderer.materials = allMaterials.ToArray(); // 赋值收集到的材质

        EditorUtility.DisplayDialog("完成", $"已将父物体的 {allMeshFilters.Length} 个子物体合并为单个模型！", "确定");
    }
}