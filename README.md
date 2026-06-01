# agentic-eng-plugin

에이전틱 엔지니어링 팀용 Claude Code 플러그인 마켓플레이스.
단일 플러그인 **`agentic-eng-toolkit`** 을 배포한다.

## 제공 커맨드

| 슬래시 커맨드 | 하는 일 | 자동 트리거 |
|---|---|---|
| `/ai-readiness-cartography` | 레포를 AI-Ready v2 루브릭(100점·7카테고리)으로 감사 → HTML 대시보드 + ROI 액션 리스트 | "AI-readiness 지도", "repo 감사 시각화" 등 |
| `/wiki-ingest` | raw 소스를 세컨드 브레인 위키에 통합(엔티티 추출·병합·교차링크·index/log 갱신) | "위키에 정리해", "ep0X 정리해줘" 등 |
| `/wiki-lint` | 위키 건강검진(모순·고아 페이지·깨진 링크·index 동기화·방치 stub) | "위키 점검", "wiki lint" 등 |
| `/wiki-query` | 위키에 질문 → 인용 붙여 종합 답변, 가치 있으면 환류 제안 | "위키에서 찾아", "...가 뭐였지" 등 |

각 커맨드는 동명의 번들 스킬을 실행한다. 슬래시로 명시 호출하거나, 위 키워드로 자동 트리거된다.

## 설치 (팀원)

```
/plugin marketplace add jha0313/agentic-eng-plugin
/plugin install agentic-eng-toolkit@agentic-eng
```

설치 후 `/help` 또는 `/` 메뉴에서 위 4개 커맨드를 확인할 수 있다.

## 전제 조건

- **wiki-* 커맨드**: 레포 루트에 `WIKI_SCHEMA.md` 와 `wiki/` 디렉터리가 있는 **세컨드 브레인 볼트 안에서** 실행해야 한다. 스키마·폴더 구조·인용 규칙을 모두 거기서 읽는다.
- **ai-readiness-cartography**: 임의 레포에서 동작. `python3` (3.10+, stdlib only) 필요. 채점 스크립트는 `${CLAUDE_PLUGIN_ROOT}/skills/ai-readiness-cartography/scripts/score.py`.

## 구조

```
agentic-eng-plugin/
├── .claude-plugin/marketplace.json     # 마켓플레이스 매니페스트
└── agentic-eng-toolkit/                # 플러그인
    ├── .claude-plugin/plugin.json
    ├── commands/                       # 4개 슬래시 커맨드
    └── skills/                         # 4개 스킬 (자동 트리거 + 커맨드가 호출)
        ├── ai-readiness-cartography/   # SKILL.md + scripts/ + assets/ + references/
        ├── wiki-ingest/
        ├── wiki-lint/
        └── wiki-query/
```

## 갱신

스킬/커맨드를 수정한 뒤 push 하면, 팀원은 `/plugin marketplace update agentic-eng` 로 최신을 받는다.
