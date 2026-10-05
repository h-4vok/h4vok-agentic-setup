"""Prueba MCP local con datos sintéticos; no llama a un proveedor de modelos.

Ejecutar con el Python del entorno uv de headroom-ai (ver verification.md).
"""

import asyncio
import json
import os
import shutil

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client


async def verify():
    executable = shutil.which("headroom")
    if not executable:
        raise RuntimeError("headroom no está en PATH")
    env = dict(os.environ, HEADROOM_BEACON="off")
    parameters = StdioServerParameters(command=executable, args=["mcp", "serve"], env=env)
    original = json.dumps([
        {"id": i, "status": "ERROR" if i == 42 else "OK", "message": "synthetic local verification", "duration_ms": 9999 if i == 42 else 10}
        for i in range(200)
    ])
    async with stdio_client(parameters) as (reader, writer):
        async with ClientSession(reader, writer) as session:
            await session.initialize()
            names = {tool.name for tool in (await session.list_tools()).tools}
            required = {"headroom_compress", "headroom_retrieve", "headroom_stats"}
            if not required <= names:
                raise RuntimeError(f"Faltan herramientas: {required - names}")
            compressed = await session.call_tool("headroom_compress", {"content": original})
            if compressed.isError:
                raise RuntimeError("headroom_compress devolvió error")
            payload = json.loads(compressed.content[0].text)
            if "error" in payload:
                raise RuntimeError(payload["error"])
            retrieved = await session.call_tool("headroom_retrieve", {"hash": payload["hash"]})
            if retrieved.isError:
                raise RuntimeError("headroom_retrieve devolvió error")
            restored = json.loads(retrieved.content[0].text)
            if restored.get("original_content") != original:
                raise RuntimeError(f"El original no coincide. Claves recibidas: {list(restored)}")
            if payload["compressed_tokens"] >= payload["original_tokens"]:
                raise RuntimeError("No hubo reducción sobre el fixture sintético")
            print(json.dumps({"result": "PASS", "tools": sorted(required), "original_tokens": payload["original_tokens"], "compressed_tokens": payload["compressed_tokens"], "retrieval_exact": True}))


if __name__ == "__main__":
    asyncio.run(asyncio.wait_for(verify(), timeout=120))
