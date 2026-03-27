import json

from google import genai

from app.config import settings

_client = None


def _get_client():
    global _client
    if _client is None:
        _client = genai.Client(api_key=settings.GOOGLE_API_KEY)
    return _client

EMOTION_ANALYZE_PROMPT = """你是一个温暖、共情的情绪分析助手。用户会给你一篇日记，请分析并返回 JSON 格式结果。

要求：
1. 识别日记中的主要情绪（从以下选项中选一个：happy, calm, anxious, sad, angry, confused, grateful）
2. 评估情绪强度（1-10，1最弱10最强）
3. 提取3-5个关键词（中文，能概括日记主题和情感的词）
4. 写一段温暖的、有深度的回应（150-250字），要求：
   - 像一个懂你的老朋友，不是心理咨询师
   - 先共情（"我感受到..."），再给出你的理解和看法
   - 可以联系生活中的小道理或小比喻
   - 语气自然温暖，不要鸡汤，不要说教，不要用"加油"之类的空话
   - 如果日记内容很短或随意，也要认真对待，从中发现有趣的点

返回严格的 JSON 格式：
{"mood": "...", "intensity": 5, "keywords": ["...", "..."], "summary": "..."}

只返回 JSON，不要其他内容。"""

MODERATION_PROMPT = """你是一个内容审核助手。判断以下文本是否适合在匿名社交平台公开展示。

需要过滤的内容：
1. 色情/暴力/极端言论
2. 广告/推销
3. 个人隐私信息（电话号码、地址、真实姓名等）
4. 恶意攻击/歧视

如果内容安全，返回：{"safe": true, "reason": ""}
如果内容不安全，返回：{"safe": false, "reason": "具体原因"}

注意：表达负面情绪（如难过、生气、迷茫）是正常的日记内容，不应被过滤。
只返回 JSON，不要其他内容。"""


def _parse_json(text: str) -> dict:
    """清理可能的 markdown 代码块并解析 JSON"""
    text = text.strip()
    if text.startswith("```"):
        text = text.split("\n", 1)[1].rsplit("```", 1)[0].strip()
    return json.loads(text)


async def analyze_emotion(content: str) -> dict:
    """分析日记情绪"""
    try:
        response = _get_client().models.generate_content(
            model="gemini-2.0-flash",
            contents=f"{EMOTION_ANALYZE_PROMPT}\n\n用户日记：\n{content}",
        )
        return _parse_json(response.text)
    except Exception as e:
        return {
            "mood": "calm",
            "intensity": 5,
            "keywords": [],
            "summary": f"AI 分析暂时不可用，但你的每一次记录都很有价值。({e})",
        }


async def moderate_content(content: str) -> dict:
    """审核内容安全性"""
    try:
        response = _get_client().models.generate_content(
            model="gemini-2.0-flash",
            contents=f"{MODERATION_PROMPT}\n\n待审核文本：\n{content}",
        )
        return _parse_json(response.text)
    except Exception:
        # 审核失败时默认通过，避免阻塞用户
        return {"safe": True, "reason": ""}
