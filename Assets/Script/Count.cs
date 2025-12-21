using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class PickupManager : MonoBehaviour
{
    public static PickupManager Instance; // 单例，方便物品触发器调用

    [Header("UI设置")]
    public Text countText; // Canvas上的文本组件（显示计数）
    public int targetCount = 9; // 目标拾取数量

    private int currentCount = 0; // 当前拾取数量

    void Awake()
    {
        // 单例初始化（确保场景中只有一个管理器）
        if (Instance == null) Instance = this;
        else Destroy(gameObject);
    }

    void Start()
    {
        // 初始化UI显示（0/9）
        UpdateCountUI();
    }

    // 外部调用：拾取一个物品时增加计数
    public void AddPickupCount()
    {
        if (currentCount < targetCount)
        {
            currentCount++;
            UpdateCountUI(); // 更新UI
        }

        // 可选：拾取满9个时触发完成事件（如弹出提示、解锁功能）
        if (currentCount == targetCount)
        {
            Debug.Log("已拾取所有9个物品！");
            // 可添加额外逻辑：如播放音效、显示完成弹窗等
        }
    }

    // 更新UI文本显示
    private void UpdateCountUI()
    {
        if (countText != null)
        {
            countText.text = $"当前收集记忆碎片数量：{currentCount}/{targetCount}";
        }
        if (currentCount==targetCount)
        {
            countText.text = "所有时光碎片已集齐！\n将前往博物馆中央的‘无界之厅’，解锁最终的顿悟";
            countText.color = Color.green;
        }
    }
}