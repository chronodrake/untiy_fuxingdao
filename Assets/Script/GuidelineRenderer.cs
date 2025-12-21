using UnityEngine;
using UnityEngine.AI;

[RequireComponent(typeof(LineRenderer))]
public class NavMeshPathLineRenderer : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Transform player;      // 玩家位置
    [SerializeField] public Transform target;      // 目标位置

    [Header("Line Renderer Settings")]
    [SerializeField] private float lineWidth = 0.1f;
    [SerializeField] private Material lineMaterial;
    [SerializeField] private Gradient lineColorGradient;

    [Header("Path Settings")]
    [SerializeField] private float updateInterval = 0.1f;  // 路径更新间隔
    [SerializeField] private float heightOffset = 0.1f;    // 路径高度偏移（避免陷入地面）

    private LineRenderer lineRenderer;
    private NavMeshPath path;
    private float timer;

    void Start()
    {
        InitializeLineRenderer();
        path = new NavMeshPath();

    }

    void InitializeLineRenderer()
    {
        lineRenderer = GetComponent<LineRenderer>();

        // 设置LineRenderer基本属性
        lineRenderer.startWidth = lineWidth;
        lineRenderer.endWidth = lineWidth;

        if (lineMaterial != null)
        {
            lineRenderer.material = lineMaterial;
        }

        lineRenderer.colorGradient = lineColorGradient;

        // 启用使用世界坐标
        lineRenderer.useWorldSpace = true;
    }

    void Update()
    {
        if (player == null || target == null)
        {
            Debug.LogWarning("Player or Target not assigned!");
            return;
        }

        // 定时更新路径，避免每帧计算
        timer += Time.deltaTime;
        if (timer >= updateInterval)
        {
            UpdatePath();
            timer = 0f;
        }

        // 实时更新路径起点为玩家位置
        if (lineRenderer.positionCount > 0)
        {
            lineRenderer.SetPosition(0, player.position + Vector3.up * heightOffset);
        }
    }

    void UpdatePath()
    {
        // 计算从玩家到目标的NavMesh路径
        if (NavMesh.CalculatePath(player.position, target.position, NavMesh.AllAreas, path))
        {
            // 如果路径有效
            if (path.corners.Length > 1)
            {
                DrawPath(path.corners);
            }
            else
            {
                // 如果玩家和目标在同一个位置，绘制一条直线
                Vector3[] straightPath = { player.position, target.position };
                DrawPath(straightPath);
            }
        }
        else
        {
            // 如果无法计算路径，绘制一条直线
            Vector3[] straightPath = { player.position, target.position };
            DrawPath(straightPath);
        }
    }

    void DrawPath(Vector3[] pathCorners)
    {
        // 为LineRenderer设置顶点数
        lineRenderer.positionCount = pathCorners.Length;

        // 设置路径点，第一个点已经是玩家位置
        for (int i = 0; i < pathCorners.Length; i++)
        {
            Vector3 pointPosition = pathCorners[i];

            // 添加高度偏移
            pointPosition.y += heightOffset;

            lineRenderer.SetPosition(i, pointPosition);
        }
    }

    #region Public Methods

    // 设置目标点
    public void SetTarget(Transform newTarget)
    {
        target = newTarget;
        UpdatePath();
    }

    // 设置目标点（Vector3）
    public void SetTarget(Vector3 targetPosition)
    {
        if (target == null)
        {
            GameObject tempTarget = new GameObject("TempTarget");
            target = tempTarget.transform;
        }
        target.position = targetPosition;
        UpdatePath();
    }

    // 设置玩家
    public void SetPlayer(Transform playerTransform)
    {
        player = playerTransform;
    }

    // 清空线条
    public void ClearLine()
    {
        lineRenderer.positionCount = 0;
    }

    // 启用/禁用线条
    public void SetLineEnabled(bool enabled)
    {
        lineRenderer.enabled = enabled;
    }

    #endregion

    #region Editor Helpers

    // 在Scene视图中绘制Gizmos（仅用于调试）
    void OnDrawGizmosSelected()
    {
        if (path != null && path.corners.Length > 1)
        {
            Gizmos.color = Color.yellow;
            for (int i = 0; i < path.corners.Length - 1; i++)
            {
                Gizmos.DrawSphere(path.corners[i], 0.1f);
                Gizmos.DrawLine(path.corners[i], path.corners[i + 1]);
            }
            Gizmos.DrawSphere(path.corners[path.corners.Length - 1], 0.1f);
        }
    }

    #endregion
}