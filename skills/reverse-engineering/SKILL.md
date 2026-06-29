name: "reverse-engineering"
description: "Binary analysis via Ghidra (PyGhidra/JPype), symbolic execution (z3-solver), and LLM-assisted decompilation (Claude + GPT-4o). Covers PE, ELF, Mach-O, raw firmware, .NET assemblies, and Java classes."
version: "1.0.0"
author: "Pravidhi"
tags: ["binary-analysis", "ghidra", "z3", "decompilation", "firmware", "malware-analysis"]

# Reverse Engineering Skill

## Capabilities
- Binary format identification (PE, ELF, Mach-O, raw)
- Ghidra headless analysis via PyGhidra
- Symbolic execution with z3-solver
- LLM-assisted decompilation (Claude/GPT-4o)
- .NET and Java bytecode analysis
- Firmware extraction and analysis
- Vulnerability pattern matching
- Exploit development assistance

## Dependencies
```
pip install pyghidra z3-solver anthropic openai
```
System: `java` (for Ghidra), `unzip`, `file`

## Usage Patterns

### Pattern 1: Binary Analysis Pipeline
```python
from engine.reverse_engineering import BinaryAnalyzer
analyzer = BinaryAnalyzer()
report = await analyzer.analyze("target.bin", depth="full")
```

### Pattern 2: Symbolic Execution
```python
from engine.reverse_engineering import SymbolicExecutor
executor = SymbolicExecutor()
result = executor.solve_constraints(constraints)
```

### Pattern 3: LLM Decompilation
```python
from engine.reverse_engineering import DecompilerAssistant
assistant = DecompilerAssistant()
explanation = await assistant.explain_function(decompiled_code)
```
