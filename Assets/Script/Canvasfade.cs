using UnityEngine;
using System.Collections;

/// <summary>
/// Canvas淡入淡出控制器
/// 依赖CanvasGroup组件，自动挂载/获取
/// </summary>
[RequireComponent(typeof(CanvasGroup))]
public class CanvasFader : MonoBehaviour
{
    [Header("淡入淡出配置")]
    [Tooltip("淡入淡出的速度（值越大越快）")]
    public float fadeSpeed = 1.5f;

    [Tooltip("是否在启动时自动淡入")]
    public bool autoFadeInOnStart = false;

    [Tooltip("初始透明度（0=完全透明，1=完全不透明）")]
    [Range(0, 1)] public float initialAlpha = 0;

    // CanvasGroup组件引用（核心控制透明度）
    private CanvasGroup _canvasGroup;

    // 是否正在执行淡入淡出动画
    private bool _isFading = false;

    private void Awake()
    {
        // 获取或自动添加CanvasGroup组件
        _canvasGroup = GetComponent<CanvasGroup>();

        // 初始化透明度
        _canvasGroup.alpha = initialAlpha;

        // 初始交互状态：透明时禁止交互
        UpdateInteractableState(initialAlpha);
    }

    private void Start()
    {
        // 自动淡入逻辑
        if (autoFadeInOnStart)
        {
            FadeIn();
        }
    }

    /// <summary>
    /// 淡入（从当前透明度到1）
    /// </summary>
    public void FadeIn()
    {
        StartCoroutine(FadeToTarget(1));
    }

    /// <summary>
    /// 淡出（从当前透明度到0）
    /// </summary>
    public void FadeOut()
    {
        StartCoroutine(FadeToTarget(0));
    }

    /// <summary>
    /// 自定义淡入淡出到指定透明度
    /// </summary>
    /// <param name="targetAlpha">目标透明度（0~1）</param>
    public void FadeTo(float targetAlpha)
    {
        // 限制目标值在0~1范围内
        targetAlpha = Mathf.Clamp01(targetAlpha);
        StartCoroutine(FadeToTarget(targetAlpha));
    }

    /// <summary>
    /// 核心淡入淡出协程
    /// </summary>
    /// <param name="targetAlpha">目标透明度</param>
    private IEnumerator FadeToTarget(float targetAlpha)
    {
        // 防止重复执行
        if (_isFading) yield break;
        _isFading = true;

        // 平滑过渡透明度
        while (!Mathf.Approximately(_canvasGroup.alpha, targetAlpha))
        {
            _canvasGroup.alpha = Mathf.MoveTowards(_canvasGroup.alpha, targetAlpha, fadeSpeed * Time.deltaTime);
            yield return null;
        }

        // 确保最终值精准
        _canvasGroup.alpha = targetAlpha;

        // 更新交互状态（透明时禁止点击/交互）
        UpdateInteractableState(targetAlpha);

        _isFading = false;
    }

    /// <summary>
    /// 根据透明度更新Canvas交互状态
    /// </summary>
    /// <param name="alpha">当前透明度</param>
    private void UpdateInteractableState(float alpha)
    {
        // 透明度接近0时，禁止交互和射线检测
        bool isInteractable = !Mathf.Approximately(alpha, 0);
        _canvasGroup.interactable = isInteractable;
        _canvasGroup.blocksRaycasts = isInteractable;
    }

    /// <summary>
    /// 立即设置透明度（无过渡动画）
    /// </summary>
    /// <param name="alpha">目标透明度</param>
    public void SetAlphaImmediately(float alpha)
    {
        alpha = Mathf.Clamp01(alpha);
        _canvasGroup.alpha = alpha;
        UpdateInteractableState(alpha);
    }
}