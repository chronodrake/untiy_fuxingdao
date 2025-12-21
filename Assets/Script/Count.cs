using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class PickupManager : MonoBehaviour
{
    public static PickupManager Instance;

    [Header("UI设置")]
    public Text countText;
    public int targetCount = 6;
    private int currentCount = 0;
    public List<Transform> targetlist = new List<Transform>();
    public Dictionary<int, Transform> itemDict = new Dictionary<int, Transform>();

    public static Transform currentTarget;

    void Awake()
    {
        if (Instance == null) Instance = this;
        else Destroy(gameObject);
    }

    void Start()
    {
        UpdateCountUI();
        InitDic();
        currentTarget = targetlist.Count > 0 ? targetlist[0] : null;
        UpdateCountUI();
    }


    public void InitDic()
    {
        itemDict.Clear();
        int actualCount = Mathf.Min(targetlist.Count, targetCount);
        for (int i = 0; i < actualCount; i++)
        {
            if (!itemDict.ContainsKey(i))
            {
                itemDict.Add(i, targetlist[i]);
            }
        }
    }


    public void AddPickupCount(int index)
    {

        Transform targetItem = itemDict[index];

        targetlist.Remove(targetItem);
        currentCount++;


        currentTarget = targetlist.Count > 0 ? targetlist[0] : null;

        Vector3 pickedPos = itemDict[index].position;
        Vector3 nextPos = currentTarget != null ? currentTarget.position : Vector3.zero;
        Debug.Log($"拾取物品位置{pickedPos}，下一个物品位置：{nextPos}");

        UpdateCountUI();

        if (currentCount == targetCount)
        {
            Debug.Log("已拾取所有6个物品！");
        }
    }

    // 更新UI文本显示
    private void UpdateCountUI()
    {
        if (countText == null) return;

        if (currentCount == targetCount)
        {
            countText.text = "所有时光碎片已集齐！\n将前往博物馆中央的‘无界之厅’，解锁最终的顿悟";
            countText.color = Color.green;
            StartCoroutine(LoadGameSceneAsync());
        }
        else
        {
            countText.text = $"当前收集记忆碎片数量：{currentCount}/{targetCount}";
        }
    }

    public void LoadGameScene()
    {
        StartCoroutine(LoadGameSceneAsync());
    }

    IEnumerator LoadGameSceneAsync()
    {
        yield return new WaitForSeconds(10f);
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync("END", LoadSceneMode.Single);

        while (!asyncLoad.isDone)
        {
            yield return null;
        }

        yield return new WaitForEndOfFrame();

        // 安全刷新光照数据
        if (LightmapSettings.lightmaps != null && LightmapSettings.lightmaps.Length > 0)
        {
            LightmapData[] lightmaps = LightmapSettings.lightmaps;
            LightmapSettings.lightmaps = lightmaps;
        }

        LightProbes.Tetrahedralize();

        Debug.Log("光照数据已重新加载");
    }
}