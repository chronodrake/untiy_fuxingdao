// 仅保留必要且兼容的命名空间（新版Zinnia/VRTK 4.x）
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using Zinnia.Action; // 核心：BooleanAction归属此命名空间（替代Zinnia.Input）
using Zinnia.Pointer; // 若需其他指针API，保留；无需则可删除

/// <summary>
/// 适配新版Zinnia/VRTK 4.x的射线UI交互（修复命名空间+事件参数）
/// </summary>
public class VRTK4_UniversalUIRaycaster : MonoBehaviour
{
    [Header("控制器与射线配置")]
    public Transform controllerTransform; // 控制器Transform（如RightControllerAlias）
    public BooleanAction selectAction; // 扳机键动作（VRTK输入绑定）
    public float rayLength = 10f; // 射线最大长度

    [Header("UI交互配置")]
    public EventSystem eventSystem; // 场景EventSystem
    public GraphicRaycaster uiRaycaster; // Canvas的GraphicRaycaster

    // UI射线检测数据
    private PointerEventData _pointerData;
    private readonly List<RaycastResult> _raycastResults = new List<RaycastResult>();
    // 记录是否已命中UI（避免重复触发）
    private GameObject _lastHitUI;

    void Awake()
    {
        // 校验核心组件
        if (controllerTransform == null)
        {
            Debug.LogError("未赋值控制器Transform！");
            enabled = false;
            return;
        }
        if (selectAction == null)
        {
            Debug.LogError("未赋值扳机键BooleanAction！");
            enabled = false;
            return;
        }
        if (eventSystem == null || uiRaycaster == null)
        {
            Debug.LogError("EventSystem/GraphicRaycaster未赋值！");
            enabled = false;
            return;
        }

        // 初始化UI射线检测
        _pointerData = new PointerEventData(eventSystem);
        // 绑定扳机键按下事件（修复：委托要求带bool参数）
        selectAction.Activated.AddListener(OnSelectPressed);
    }

    void Update()
    {
        // 可视化射线（调试用）
        Debug.DrawRay(controllerTransform.position, controllerTransform.forward * rayLength, Color.cyan);

        // 清空上一帧结果
        _raycastResults.Clear();
        // 执行UI射线检测
        _pointerData.position = new Vector2(0.5f, 0.5f); // World Space UI占位
        uiRaycaster.Raycast(_pointerData, _raycastResults);

        // 更新当前命中的UI
        _lastHitUI = _raycastResults.Count > 0 ? _raycastResults[0].gameObject : null;
    }

    /// <summary>
    /// 扳机键按下时触发UI点击（修复：添加bool参数匹配委托类型）
    /// </summary>
    /// <param name="isPressed">按键是否按下（Zinnia事件强制要求的参数）</param>
    private void OnSelectPressed(bool isPressed)
    {
        // 仅在按键按下时触发（避免松开时重复触发）
        if (isPressed && _lastHitUI != null)
        {
            // 触发原生UI点击事件
            eventSystem.SetSelectedGameObject(_lastHitUI);
            ExecuteEvents.Execute(_lastHitUI, _pointerData, ExecuteEvents.pointerClickHandler);
            Debug.Log($"触发UI点击：{_lastHitUI.name}");
        }
    }

    void OnDestroy()
    {
        if (selectAction != null)
        {
            // 解除事件绑定时，参数类型已匹配
            selectAction.Activated.RemoveListener(OnSelectPressed);
        }
    }
}