# AI Agent Skills Repository Scaffold

다양한 제작사(OpenAI, Anthropic, Google, Meta, Microsoft 등)의 AI 에이전트 스킬을 한 저장소에서 관리하기 위한 기본 스캐폴딩입니다.

## 구조

- `vendors/<vendor>/skills/`: 제작사별 스킬 저장 위치
- `community/skills/`: 커뮤니티 기여 스킬
- `templates/skill-starter/`: 새 스킬 시작 템플릿
- `scripts/new-skill.sh`: 스킬 폴더 빠른 생성 스크립트

## 빠른 시작

```bash
./scripts/new-skill.sh openai web-search-helper
./scripts/new-skill.sh anthropic cli-troubleshooter
./scripts/new-skill.sh community prompt-auditor
```

## 규칙

- 스킬명은 소문자/숫자/하이픈(`-`)만 허용
- 각 스킬은 최소 `SKILL.md` 포함
- 필요 시 `agents/`, `references/`, `scripts/`, `assets/` 하위 폴더 추가
