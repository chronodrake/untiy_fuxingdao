using UnityEditor;
using UnityEngine;

public class BatchAddCollider : EditorWindow
{
    // 添加上下文菜单（在编辑器中右键物体可触发）
    [MenuItem("GameObject/批量添加Mesh碰撞体（含子物体）")]
    static void AddMeshColliderToSelected()
    {
        // 获取当前选中的所有物体
        GameObject[] selectedObjs = Selection.gameObjects;
        if (selectedObjs.Length == 0)
        {
            EditorUtility.DisplayDialog("提示", "请先选中需要添加碰撞体的物体！", "确定");
            return;
        }

        int addedCount = 0;
        // 遍历每个选中的物体，递归处理所有子物体
        foreach (GameObject obj in selectedObjs)
        {
            AddColliderToObjAndChildren(obj.transform, ref addedCount);
        }

        EditorUtility.DisplayDialog("完成", $"已给 {addedCount} 个物体添加了Mesh碰撞体！", "确定");
    }

    // 递归遍历子物体，添加Mesh Collider（避免重复添加）
    static void AddColliderToObjAndChildren(Transform parent, ref int count)
    {
        // 若物体已有Collider，跳过
        if (parent.GetComponent<Collider>() == null)
        {
            // 添加Mesh Collider（静态物体无需勾Convex，性能更优）
            MeshCollider collider = parent.gameObject.AddComponent<MeshCollider>();
            collider.isTrigger = false; // 确保是物理碰撞，不是触发器
            count++;
        }

        // 递归处理所有子物体
        foreach (Transform child in parent)
        {
            AddColliderToObjAndChildren(child, ref count);
        }
    }
}