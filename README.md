# :pushpin: MILIE-login-CloneCoding
Firebase Authentication을 활용한 밀리의 서재 앱(ver 5.4.1) 로그인/회원가입 클론코딩
>제작 기간: 2023.04 ~ 진행중</br>
>참여 인원: 개인 프로젝트


</br>


## 기술 스택
- UIKit / UIStoryboard
- Firebase Authentication / Firebase Realtime Database
- URLSession
- MVVM Architecture


</br>


## 기능 구현
### 1. 화면
|<img src="" alt>|<img src="" alt>|<img src="" alt>|
|:--:|:--:|:--:|
| | | |


</br>


### 2. View

- **UIStoryboard**
  - 스토리보드를 주로 사용하고, 모달 ViewController는 코드로 구현했습니다.
  - @IBInspectable Attributes를 사용하여 화면에 관련된 코드 작성을 최소화했습니다.
  
- **Custom UI Component**
  - 반복되는 입력 컨트롤을 스토리보드에서 렌더링되도록 .xib로 작성했습니다.
  

</br>


### 3. Database

- Firebase Realtime Database
  - email이 아닌 전화번호로 로그인하는 본 앱을 구현하기 위해 다양한 user 정보를 저장할 수 있게 db를 사용했습니다.


</br>


### 4. 네트워크  

- URLSession
  - db에 접근하기 위한 네트워크 통신 코드 작성
  - Async, Await


</br>


### 5. Login

- firebase 기본 로그인
- firebase 전화번호 인증 로그인
- google 로그인
- apple 로그인
- kakao 로그인
- naver 로그인
- facebook 로그인


</br>


## 트러블 슈팅 
### 1. 회원정보 입력값 정규화
  - 
  
  
</br>

  
### 2. 화면변환 및 UITextField 커서이동
  - 
