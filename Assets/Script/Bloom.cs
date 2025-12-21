using UnityEngine;

public class GlowWithExistingMaterial : MonoBehaviour
{
    [Header("发光参数")]
    public Color glowColor = new Color(3, 3, 0); // HDR发光色（RGB>1）
    public float glowIntensity = 1f; // 发光强度
    public bool isPersistent = false; // 是否永久开启发光（false则仅临时）

    private MeshRenderer _meshRenderer;
    private Material _instanceMaterial; // 材质实例（不影响全局）
    // 不同管线的Emission属性名（自动适配）
    private string _emissionKey;
    private Color _originalEmissionColor; // 保存原有发光色，用于恢复

    void Start()
    {
        // 获取模型已有材质（无需手动绑定）
        _meshRenderer = GetComponent<MeshRenderer>();
        if (_meshRenderer == null || _meshRenderer.material == null)
        {
            Debug.LogError("模型无MeshRenderer或材质！");
            return;
        }

        // 1. 创建材质实例（避免修改全局材质）
        _instanceMaterial = new Material(_meshRenderer.material);
        _meshRenderer.material = _instanceMaterial;

        // 2. 自动识别管线，适配Emission属性名
        if (_instanceMaterial.shader.name.Contains("High Definition"))
        {
            _emissionKey = "_EmissiveColor"; // HDRP
        }
        else
        {
            _emissionKey = "_EmissionColor"; // Built-in/URP
        }

        // 3. 保存原有发光色，开启Emission
        _originalEmissionColor = _instanceMaterial.GetColor(_emissionKey);
        _instanceMaterial.EnableKeyword("_EMISSION"); // 强制开启发光
    }

    void Update()
    {
        // 示例：按空格键切换发光/恢复原状
        if (Input.GetKeyDown(KeyCode.Space))
        {
            ToggleGlow();
        }
    }

    // 切换发光/恢复原状
    void ToggleGlow()
    {
        if (_instanceMaterial.GetColor(_emissionKey) == glowColor * glowIntensity)
        {
            // 恢复原有材质状态
            _instanceMaterial.SetColor(_emissionKey, _originalEmissionColor);
            if (!isPersistent) _instanceMaterial.DisableKeyword("_EMISSION");
        }
        else
        {
            // 开启发光（复用原有材质，仅改发光色）
            _instanceMaterial.SetColor(_emissionKey, glowColor * glowIntensity);
        }
    }

    // 销毁时恢复原有材质（可选）
    void OnDestroy()
    {
        if (_instanceMaterial != null)
        {
            _meshRenderer.material = _meshRenderer.sharedMaterial;
            Destroy(_instanceMaterial);
        }
    }
}