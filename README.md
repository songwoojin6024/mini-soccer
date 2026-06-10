# Mini Soccer

Godot Engine으로 제작한 2D 미니 축구 게임입니다.  
플레이어는 캐릭터를 선택한 뒤 AI 팀들과 토너먼트 방식으로 경기를 진행하며, 결승에서 우승하면 랜덤 유물을 획득할 수 있습니다.

## 프로젝트 소개

Mini Soccer는 Head Soccer에서 영감을 받아 제작한 캐주얼 2D 축구 게임입니다.  
단순한 1회성 경기가 아니라 8강, 4강, 결승으로 이어지는 토너먼트 구조를 도입하여 게임의 목표와 진행감을 높였습니다.

플레이어는 캐릭터를 선택하고 랜덤 대진을 통해 AI 팀과 경쟁합니다. 경기 중에는 바람, 야간, 폭염, 폭설 등 랜덤 환경 이벤트가 발생하여 매 경기 다른 변수를 경험할 수 있습니다.

## 주요 기능

- 캐릭터 선택 기능
- AI 상대와 1대1 축구 경기
- 8강, 4강, 결승 토너먼트 진행
- 랜덤 토너먼트 대진 생성
- 슛 게이지를 통한 슛 세기 조절
- 전반/후반 랜덤 환경 이벤트
  - 바람
  - 야간 경기
  - 폭염
  - 폭설
- 우승 시 랜덤 유물 보상
- ESC 일시정지 메뉴
- 경기장 배경음 및 공 타격음

## 조작법

| 키 | 기능 |
|---|---|
| ← / → | 이동 |
| ↑ | 점프 |
| ↓ | 슬라이드 |
| d 키 | 슛 차징 및 발사 |
| ESC | 일시정지 |

## 개발 환경

- Engine: Godot Engine 4.6.2
- Language: GDScript
- Platform: Windows
- Assets: PNG 이미지, MP3 사운드

## 주요 파일 구조

```text
mini-soccer
├─ project.godot
├─ main_menu.tscn
├─ main_menu.gd
├─ tournament.tscn
├─ tournament.gd
├─ main.tscn
├─ main.gd
├─ game_manager.gd
├─ player.tscn
├─ player.gd
├─ ai.tscn
├─ ai.gd
├─ ball.tscn
├─ ball.gd
├─ characters
└─ image soccer
```

## 프로젝트 특징
기존 Head Soccer류 게임과 달리 슛 게이지를 추가하여 공을 약하게 또는 강하게 찰 수 있도록 하였습니다.
또한 전반과 후반에 랜덤 환경 이벤트가 발생하도록 하여 경기마다 다른 상황이 만들어지도록 구현했습니다.

