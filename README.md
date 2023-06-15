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
* Firebase (Firestore & Auth)
* UserDefaults
* KakaoMap API SDK (DaumMap)
* MVVM
* WKWebView
* Alamofire
* JGProgressHUD
* Toast
<br>
<br>
<br>

### Firestore 데이터 구조
---
<img width="489" alt="image" src="https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/6b635208-1f82-46b0-8174-b46021a15b66">
<img width="506" alt="image" src="https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/0eb33c6d-1070-4702-a3f6-b6c52c5dd54c">
<br>
<br>
<br>

### 구현 기능
---
* 카카오, 구글 로그인
* 현재위치/지도 중심 장소 검색 및 거리순/정확도순 정렬 
* 키워드 선택하여 검색
* 검색 기록으로 재검색 혹은 장소 정보 확인
* 해당 장소로 가는 자동차 경로 확인
* 해당 장소에 대한 카카오맵 평점 및 리뷰 확인
* 로그인 유저에게 장소 즐겨찾기 기능 제공
* 전화번호 제공 업체인 경우 업체 전화 기능
<br>
<br>
<br>

### 진행 기간
---
2023.05.23 ~ 6.15
<br>
<br>
<br>

### 시연 영상
---
![ezgif-2-1c036475d4](https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/dcbabaf0-e162-4a5f-ac95-c828ebf58fa1)
![ezgif-2-9cb88c6691](https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/e9b3c3b7-369d-4560-86c5-f3adabec683e)
![ezgif-2-e6e930e99e](https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/7a787eef-29fd-47f2-bf3f-7fde3edeeb5d)
![ezgif-1-117834d42c](https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/496a09e9-9c8a-44fd-9614-766ee3b170ec)
![ezgif-1-a57f5fe2d0](https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/1a302aa5-424c-4a54-b970-36a49fda6580)
![ezgif-5-9c972ac2e1](https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/d901ebdd-4390-4082-9918-23bca6a5e1e1)
![ezgif-5-bc3add653b](https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/3b7f4f26-ab58-42f4-a600-677b0d617ba3)
<br>
<br>
<br>

### 문제해결 및 과정
---
#### 문제 상황 1
currentLocationTrackingMode 사용 시 경고 발생 <br>
Authorization status 확인 후, currentLocationTrackingMode를 실행했음에도 불구하고 해당 경고 메세지가 지속적으로 발생 <br>
<img width="917" alt="image" src="https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/5d031c22-ce0c-4ac7-a7f7-77c68d1dd046">
<img width="924" alt="image" src="https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/7e63ced5-7b58-472a-af39-58ca0d28c133">
<br>

#### 해결 방법 및 과정
경고 메세지를 다시 읽어보니, 해당 코드의 실행시점에만 집중하고 UI 관련된 코드가 아니라는 경고 메세지 부분을 간과했었다. <br>
mapView의 센터 위치를 잡는 코드를 제외한, mapView 설정하는 코드를 global queue에서 async하게 동작하도록 수정하여 문제를 해결할 수 있었다. <br>
꼼꼼하게 경고 메세지를 확인하고 대처하는 것이 중요하다는 것을 다시 한번 깨달았다.
<img width="931" alt="image" src="https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/704fd6ea-ccb3-43e4-ac94-a1a78cc3fb10">
<br>
<br>

#### 문제 상황 2
지도 버튼을 누르면, 검색 결과를 지도 좌표에 찍어서 보여주는 view를 띄우기 + 목록 버튼 누르면, 검색 결과 화면 tableView 띄우기 구현 방법에 대한 고민 <br>

<img width="669" alt="image" src="https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/79ba13aa-4b35-4028-a61c-5bc58613e8cd">
<br>

#### 해결 방법 및 과정
  맨 처음에는 tableView와 지도view를 담고, case문에 따라 다른 view를 보여주는 방식으로 구현할까 고민했다. 그러다 카카오맵 앱에 들어가서 두 버튼을 누르며 화면을 보니, 아주 미세하게 정렬 버튼의 위치가 달라지는 것을 발견했다.(아마 카카오측에서 발견하지 못한 아주 미세한 UI 오류인듯하다...)<br>  
  해당 현상을 보고, 하단의 view를 교체하는 방식으로 구현이 되어있지 않음을 인지하고 ResultMapViewController를 생성하여 지도모양 버튼을 누르면 해당 화면을 띄우도록 UI를 구현했다. <br>
    <img width="662" alt="image" src="https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/274aabdd-0a9f-461c-86cf-1a89cd6491fc">
  ![캡처본1](https://github.com/samusesapple/KakaoMap_Clone/assets/126672733/e4e7a9d1-4296-424d-9c69-eefaec005e6a)



