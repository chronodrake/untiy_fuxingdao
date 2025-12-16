using UnityEngine;
using UnityEngine.SceneManagement; // 引入场景管理命名空间
using System.Collections;

public class StartMenuManager : MonoBehaviour
{
    // 这个方法将被绑定到"开始"按钮的点击事件
    public void LoadGameScene()
    {
        // 使用异步加载并确保光照正确初始化
        StartCoroutine(LoadGameSceneAsync());
        //SceneManager.LoadScene("Main");
    }

    IEnumerator LoadGameSceneAsync()
    {
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync("Main", LoadSceneMode.Single);

        // 等待场景加载
        while (!asyncLoad.isDone)
        {
            yield return null;
        }

        // 场景加载完成后，强制重新加载光照数据
        yield return new WaitForEndOfFrame();

        // 重新加载光照贴图
        if (LightmapSettings.lightmaps != null && LightmapSettings.lightmaps.Length > 0)
        {
            LightmapData[] lightmaps = LightmapSettings.lightmaps;
            LightmapSettings.lightmaps = lightmaps; // 重新赋值以刷新
        }

        // 重新生成光照探头的四面体化
        LightProbes.Tetrahedralize();

        Debug.Log("光照数据已重新加载");
    }

    // 你可以根据需要添加其他方法，例如退出游戏
    public void QuitGame()
    {
        Application.Quit();
        // 在Unity编辑器中，上一行代码不会生效，通常我们会用下面这行来模拟退出状态
        // UnityEditor.EditorApplication.isPlaying = false;
    }
}