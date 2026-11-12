# AI 활용 포트폴리오 종합 정리 — 자소서 작성용 근거자료

> 이 문서는 GitHub 업로드용 README와 별개로, SK하이닉스 자소서 문항 작성 시 STAR(상황-과제-행동-결과) 구조에 바로 대입할 수 있도록 프로젝트별 세부 내용을 정리한 자료입니다. `[ ]` 표시된 항목은 실제 수치로 채워 넣어야 합니다.

---

## 프로젝트 1. BeamPath — Virtual Optics System (광학계 Fluence 계산기)

### 상황 (Situation)
- 355nm UV 나노초 레이저 공정에서 fluence·spot size를 잡을 때마다 Gaussian beam propagation 수식을 수동으로 반복 계산해야 했음.
- 계산 실수 시 공정 조건이 어긋나거나, 조건을 바꿀 때마다 [소요 시간] 정도 걸림.

### 과제 (Task)
- 실측 논문 데이터(focal waist w₀′=96μm, M²=1.2, f=255mm)를 기준으로, 스캐너-스테이지 거리 변화에 따른 fluence를 실시간으로 계산하고 시각화하는 도구가 필요했음.
- 동시에 AI 활용 역량을 입증할 포트폴리오 결과물로 완성도를 갖춰야 했음.

### 행동 (Action)
- Claude와 반복 대화를 통해 요구사항을 구체화: 실제 광학계 토폴로지(Atten., Shutter, BET, M1–M5, Waveplate, Scanner, Stage)를 그대로 반영한 애니메이션 SVG 경로 구현.
- 물리 모델은 본인이 직접 검증: Rayleigh range 공식, defocus에 따른 spot size 변화 로직을 논문 수치와 대조.
- 목표 fluence/spot diameter를 입력하면 필요 스테이지 거리를 역산하는 reverse-solve 기능 추가.
- v1~v16까지 반복 개선하며 UI/UX와 계산 정확도를 함께 다듬음.

### 결과 (Result)
- [실사용 시 계산 소요시간 단축률]
- [공정 조건 설정 오류 감소 여부]
- 단일 파일 HTML로 배포되어 연구실 내 공유·재사용 가능한 형태로 완성.

---

## 프로젝트 2. Raman Xc Mapper (a-Si 결정화 정량 분석)

### 상황 (Situation)
- a-Si 박막 레이저 결정화 실험에서 25×25 grid(625 point) Raman mapping 데이터를 MATLAB으로 수동 분석하고 있었음.
- 결정화율(Xc) 계산 시 사용하는 α 파라미터가 문헌마다 0.1~1.7로 크게 달라 절대값 해석에 불확실성이 있었음.

### 과제 (Task)
- MATLAB 파이프라인의 분석 로직(despike filtering, peak band integration, zone classification)을 재현하면서도, α 불확실성 문제를 과학적으로 타당하게 처리하는 시각화 도구가 필요했음.

### 행동 (Action)
- Claude와 함께 despike filtering(median filter + MAD threshold), 3종 동기화 히트맵(a-Si/c-Si/Xc), cross-section 프로파일을 구현.
- **핵심 판단**: α의 절대값 불확실성에도 불구하고 결정화 분포의 공간적 상대 패턴(spatial ordering)은 α 선택과 무관하게 불변함을 확인 — 이를 근거로 절대 Xc값이 아닌 상대 분포 기반 해석 전략을 채택.
- Otsu automatic thresholding을 시도했으나 데이터가 bimodal distribution을 따르지 않아 부적합하다고 판단, φ classification에만 제한 적용하고 signal floor는 수동 제어로 전환 — 자동화의 한계를 데이터 특성에 근거해 직접 검증하고 수정한 사례.

### 결과 (Result)
- [MATLAB 대비 분석 소요시간 단축률]
- 문헌 기반 파라미터 불확실성을 정면으로 다루고, 이를 우회하는 대안적 분석 전략(상대 패턴 기반 해석)을 스스로 도출 — 단순 도구 제작을 넘어 분석 방법론 자체를 개선한 사례.

---

## 프로젝트 3. SCANLAB Studio (레이저 스캐너 툴패스 설계·검증)

### 상황 (Situation)
- SCANLAB 스캐너 시스템은 single-stroke(Eulerian) 경로만 실행 가능한데, 코드만으로 복잡한 툴패스를 예측하면 실제 장비 동작과 어긋나는 경우가 잦아 장비 시간이 낭비됨.

### 과제 (Task)
- 물리적 실행 전 툴패스 형태·속도 분포·타이밍을 시각적으로 미리 검증할 수 있는 도구가 필요했음.

### 행동 (Action)
- 이미지 업로드 → contour 추출(marching squares + Douglas-Peucker) → 경로 최적화(nearest-neighbor + 2-opt) → 애니메이션 미리보기까지 이어지는 파이프라인을 Claude와 함께 설계·구현.
- .sld export(UTF-16LE 인코딩) 과정에서 mm/s와 m/s 단위를 혼동한 1000배 스케일 오차가 발생 — 이를 실제 장비 테스트로 직접 발견하고 원인을 추적해 수정.
- 실제 장비에서 물리적 스캔 실행까지 성공적으로 검증.

### 결과 (Result)
- [장비 시행착오 횟수 감소 / 시간 단축률]
- 시뮬레이션 도구를 통해 검증한 뒤 실장비에 적용하는 워크플로우를 확립 — 문제 진단(단위 오류) → 원인 추적 → 해결까지의 전체 사이클을 직접 경험한 사례로, "현장형 문제해결 엔지니어" 어필에 직접 활용 가능.

---

## 자소서 활용 시 참고 — 문항 유형별 매핑 제안

| 자소서 문항 유형 | 가장 적합한 프로젝트 | 이유 |
|---|---|---|
| AI/데이터 활용 역량 | Raman Xc Mapper | α 불확실성이라는 애매한 문제를 데이터 특성 기반으로 판단·해결 |
| 문제해결/트러블슈팅 경험 | SCANLAB Studio | 실제 단위 오류 발견 → 원인 추적 → 해결의 완결된 사례 |
| 전공/도메인 전문성 | BeamPath | Gaussian beam propagation 등 광학 이론을 직접 도구로 구현 |
| 지원 동기 (공정/장비 직무 연결) | 3개 종합 | "연구 문제를 도구화하는 습관"을 공정 자동화·장비 트러블슈팅 직무와 연결 |

## 다음 단계

1. 위 `[ ]` 표시된 정량 지표 채우기 (실제 계산/사용 시간 비교 등)
2. 지원 직무(소자/공정/PE)에 맞춰 어느 프로젝트를 메인으로 내세울지 결정
3. 문항별 답변 초안 작성 요청
