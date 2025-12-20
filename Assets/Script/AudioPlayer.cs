using UnityEngine;

public class ActivatePlaySound : MonoBehaviour
{
    [Header("音效设置")]
    [SerializeField] private AudioClip activateSound; // 激活时播放的音效文件
    [SerializeField] private float soundVolume = 1f; // 音效音量（0-1）
    [SerializeField] private bool isLoop = false; // 是否循环播放（激活音效一般设为false）

    private AudioSource audioSource; // 音频播放组件

    void Awake()
    {
        // 自动给物体添加AudioSource组件（无需手动添加）
        audioSource = gameObject.GetComponent<AudioSource>();
        if (audioSource == null)
        {
            audioSource = gameObject.AddComponent<AudioSource>();
        }

        // 配置AudioSource属性
        audioSource.clip = activateSound;
        audioSource.volume = soundVolume;
        audioSource.loop = isLoop;
        audioSource.spatialBlend = 0; // 0=2D音效（全局播放），1=3D音效（随位置衰减）
    }

    // 物体激活时调用（包括场景加载时激活、手动SetActive(true)）
    void OnEnable()
    {
        // 避免音效为空时报错
        if (activateSound != null && audioSource != null)
        {
            audioSource.Play(); // 播放音效
        }
    }

    // 可选：手动触发播放（如需通过按钮等事件调用）
    public void PlaySoundManually()
    {
        if (activateSound != null && audioSource != null)
        {
            audioSource.PlayOneShot(activateSound, soundVolume); // 播放一次（不打断当前音效）
        }
    }
}