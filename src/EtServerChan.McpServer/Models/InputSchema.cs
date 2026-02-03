using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace EtServerChan.McpServer.Models;

/// <summary>
/// Server酱消息输入参数模型
/// </summary>
internal class InputSchema
{
    /// <summary>
    /// 消息标题（必填）
    /// </summary>
    [Required]
    [Description("消息标题，必填，最大长度 256 字符")]
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// 消息正文内容（可选，支持 Markdown 格式）
    /// </summary>
    [Description("消息正文内容，可选，支持 Markdown 格式")]
    public string? Content { get; set; }
}