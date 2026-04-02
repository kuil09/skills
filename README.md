# Skills

A collection of reusable AI agent skills — structured frameworks that guide agents to reason and act more rigorously.

---

## Skills

### [`hypothesis-driven-task-execution`](./hypothesis-driven-task-execution/SKILL.md)

A scientific thinking framework that treats every piece of information — user requests, agent responses, feedback, and experiment results — as a hypothesis to be verified through falsification-first experimentation.

**When to use:** investigation, debugging, root cause analysis, validating assumptions, or any task involving uncertainty or competing explanations.

**Key concepts:**
- **5 Hypothesis Layers (L1–L5):** source-aware classification of every claim (user request → agent response → user feedback → experiment interpretation → external knowledge)
- **6-Phase Protocol:** Observe → Hypothesize → Predict → Experiment → Analyze → Conclude
- **Falsification-first:** attempt to disprove a hypothesis before seeking confirmation
- **Confidence scale:** speculation → low → medium → high (based on independent falsification attempts survived)
- **Safeguards:** hypothesis budget (max 5 active), iteration cap (max 5 primary loops), confirmation-bias guards

---

## Usage

Each skill is defined in a `SKILL.md` file and can be referenced in agent system prompts, task instructions, or tool configurations. Skills are designed to be composable and applicable proportionally — use full rigor for complex investigations, lighter application for mechanical tasks.

---

---

# Skills (한국어)

재사용 가능한 AI 에이전트 스킬 모음 — 에이전트가 더 엄밀하게 추론하고 행동할 수 있도록 안내하는 구조화된 프레임워크입니다.

---

## 스킬 목록

### [`hypothesis-driven-task-execution`](./hypothesis-driven-task-execution/SKILL.md)

모든 정보(사용자 요청, 에이전트 응답, 피드백, 실험 결과)를 반증(falsification) 우선 실험을 통해 검증해야 할 **가설**로 취급하는 과학적 사고 프레임워크입니다.

**적용 상황:** 조사, 디버깅, 근본 원인 분석, 가정 검증, 또는 불확실성이나 경쟁하는 설명이 존재하는 모든 작업.

**핵심 개념:**
- **5단계 가설 계층 (L1–L5):** 모든 주장의 출처별 분류 (사용자 요청 → 에이전트 응답 → 사용자 피드백 → 실험 해석 → 외부 지식)
- **6단계 프로토콜:** 관찰(Observe) → 가설 수립(Hypothesize) → 예측(Predict) → 실험(Experiment) → 분석(Analyze) → 결론(Conclude)
- **반증 우선 원칙:** 가설을 확인하기 전에 먼저 반증을 시도
- **신뢰도 척도:** 추측(speculation) → 낮음(low) → 중간(medium) → 높음(high) (독립적인 반증 시도 생존 횟수 기반)
- **안전 장치:** 가설 예산(최대 활성 5개), 반복 상한(기본 루프 최대 5회), 확증 편향 방지 장치

---

## 사용 방법

각 스킬은 `SKILL.md` 파일에 정의되어 있으며, 에이전트 시스템 프롬프트, 태스크 지시문, 또는 도구 설정에서 참조할 수 있습니다. 스킬은 조합 가능하며 비례적으로 적용하도록 설계되었습니다 — 복잡한 조사에는 완전한 엄밀도를, 기계적인 작업에는 가벼운 적용을 사용하세요.

---

---

# Skills (日本語)

再利用可能な AI エージェントスキルのコレクション — エージェントがより厳密に推論・行動できるよう導く構造化されたフレームワークです。

---

## スキル一覧

### [`hypothesis-driven-task-execution`](./hypothesis-driven-task-execution/SKILL.md)

すべての情報（ユーザーリクエスト、エージェントの応答、フィードバック、実験結果）を、反証優先（falsification-first）の実験によって検証すべき**仮説**として扱う科学的思考フレームワークです。

**適用場面:** 調査、デバッグ、根本原因分析、前提条件の検証、または不確実性や競合する説明が存在するあらゆるタスク。

**主要概念:**
- **5段階の仮説レイヤー (L1–L5):** すべての主張のソース別分類（ユーザーリクエスト → エージェント応答 → ユーザーフィードバック → 実験解釈 → 外部知識）
- **6フェーズ・プロトコル:** 観察(Observe) → 仮説化(Hypothesize) → 予測(Predict) → 実験(Experiment) → 分析(Analyze) → 結論(Conclude)
- **反証優先の原則:** 仮説を確認する前に、まず反証を試みる
- **信頼度スケール:** 推測(speculation) → 低(low) → 中(medium) → 高(high)（独立した反証試行の生存回数に基づく）
- **セーフガード:** 仮説予算（最大アクティブ5件）、反復上限（基本ループ最大5回）、確証バイアス防止策

---

## 使い方

各スキルは `SKILL.md` ファイルに定義されており、エージェントのシステムプロンプト、タスク指示、またはツール設定から参照できます。スキルは組み合わせ可能で、比例的に適用できるよう設計されています — 複雑な調査には完全な厳密さを、機械的なタスクには軽い適用を使用してください。
