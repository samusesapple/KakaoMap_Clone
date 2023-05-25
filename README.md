# KakaoMap_Clone

### 프로젝트 목적
---
카카오맵 클론 코딩을 통한 위치 기반 서비스 구현하기
<br>
<br>
<br>


### 사용 기술, 라이브러리 및 프레임워크
---
* Core Location
* KakaoMap API SDK (DaumMap)
* MVVM
* Alamofire
* JGProgressHUD
<br>
<br>
<br>


### 진행 기간
---
2023.05.23 ~ (진행 중)
<br>
<br>
<br>


### 문제해결 및 과정
---
#### 문제 상황
* currentLocationTrackingMode 사용 시 경고 발생 <br>
Authorization status 확인 후, currentLocationTrackingMode를 실행했음에도 불구하고 해당 경고 메세지가 지속적으로 발생 <br>
<img width="917" alt="image" src="https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/5d031c22-ce0c-4ac7-a7f7-77c68d1dd046">
<img width="924" alt="image" src="https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/7e63ced5-7b58-472a-af39-58ca0d28c133">
<br>

#### 해결 방법 및 과정
경고 메세지를 다시 읽어보니, 해당 코드의 실행시점에만 집중하고 UI 관련된 코드가 아니라는 경고 메세지 부분을 간과했었다. <br>
mapView의 센터 위치를 잡는 코드를 제외한, mapView 설정하는 코드를 global queue에서 async하게 동작하도록 수정하여 문제를 해결할 수 있었다. <br>
꼼꼼하게 경고 메세지를 확인하고 대처하는 것이 중요하다는 것을 다시 한번 깨달았다.
<img width="931" alt="image" src="https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/704fd6ea-ccb3-43e4-ac94-a1a78cc3fb10">



