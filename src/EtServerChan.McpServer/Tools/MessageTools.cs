using System.ComponentModel;
using EtServerChan.McpServer.Models;
using ModelContextProtocol.Server;

namespace EtServerChan.McpServer.Tools;

/// <summary>
/// Server酱消息推送工具类
/// 提供通过 Server酱 API 向微信发送推送消息的功能
/// </summary>
internal class MessageTools
{
    /// <summary>
    /// 发送消息到 Server酱（微信推送）
    /// </summary>
    /// <param name="input">包含消息标题和内容的输入参数</param>
    /// <param name="cancellationToken">用于取消异步操作的令牌</param>
    /// <returns>Server酱 API 的响应结果，包含推送状态信息</returns>
    /// <remarks>
    /// 需要在环境变量中配置 SERVERCHAN_KEY（Server酱的 SendKey）
    /// SendKey 可在 https://sct.ftqq.com/ 登录后获取
    /// </remarks>
    [McpServerTool(Name = "send_message")]
    [Description("发送消息到 Server酱（微信推送）。通过 Server酱 API 将消息推送到微信，需要配置 SERVERCHAN_KEY 环境变量。")]
    public async Task<string> SendMessageAsync(
        [Description("消息标题和内容，title 为必填的消息标题，content 为可选的消息正文（支持 Markdown 格式）")]
        InputSchema input,
        CancellationToken cancellationToken)
    {
        // 从环境变量获取 Server酱 SendKey
        var serverchanKey = Environment.GetEnvironmentVariable("SERVERCHAN_KEY");
        if (string.IsNullOrWhiteSpace(serverchanKey))
        {
            return "{\"error\": \"SERVERCHAN_KEY 环境变量未配置，请在 .mcp/server.json 中配置或设置系统环境变量\"}";
        }

        // 构建 Server酱 API 请求 URL
        // API 文档: https://sct.ftqq.com/sendkey
        var apiUrl = $"https://sctapi.ftqq.com/{serverchanKey}.send";
        
        // 构建请求参数
        // text: 消息标题（必填）
        // desp: 消息内容（可选，支持 Markdown）
        var parameters = new Dictionary<string, string>
        {
            ["text"] = input.Title
        };
        
        if (!string.IsNullOrEmpty(input.Content))
        {
            parameters["desp"] = input.Content;
        }

        // 发送 POST 请求到 Server酱 API
        using var client = new HttpClient();
        var response = await client.PostAsync(apiUrl, new FormUrlEncodedContent(parameters), cancellationToken);
        var respString = await response.Content.ReadAsStringAsync(cancellationToken);

        return respString;
    }
}