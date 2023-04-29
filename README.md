# :pushpin: MILIE-login-CloneCoding
Firebase Authentication을 활용한 밀리의 서재 앱(ver 5.4.1) 로그인/회원가입 클론코딩
>제작 기간: 2023.04 ~ 2023.04</br>
>참여 인원: 개인 프로젝트

</br>

## 기술 스택
- UIKit / UIStoryboard
- Firebase Authentication / Firebase Realtime Database
- MVC Architecture


</br>


## 기능 구현
### 1. 화면
|<img src="" alt>|<img src="" alt>|<img src="" alt>|
|:--:|:--:|:--:|
| | | |


</br>


### 2. View

- UIStoryboard
  - 스토리보드를 주로 사용하고, 일부 ModalView는 코드로 구현했습니다.
  - @IBInspectable Attributes를 사용하여 화면에 관련된 코드 작성을 최소화했습니다.
  
- Custom UI Component (.xib)
  - 2번 이상 사용되면서 코드작성이 길고 중복되는 UI를 재사용 가능하게 구현했습니다.
  - SocialView - 소셜 로그인/회원가입
  - TermsofUseCollectionView - 기본로그인/소셜로그인 약관동의
  - InputStackView - 텍스트 입력필드


</br>


### 2. 네트워크  

- Async, Await URLSession
  - 네이버 로그인 API
  - LocalServer
  - Firebase Realtime Database


</br>


### 3. Login

- 기본 로그인
  - Firebase 전화번호 인증 Sign
- kakao 로그인
  - Kakao Open SDK
  - Firebase CustomToken Sign
- naver 로그인
  - Naver Id Login SDK
  - Firebase CustomToken Sign
- facebook 로그인
  - Facebook SDK
  - Firebase AuthCredential Sign
- apple 로그인
  - Firebase AuthCredential Sign
- google 로그인
  - Google Sign In SDK
  - Firebase AuthCredential Sign


</br>


## 트러블 슈팅
### 1. UITextField Delegate
  - 상황: UITextField의 입력값이 조건을 만족했을 때, 다음 필드가 Visible되면서 포커스가 가는 동작을 구현해야했습니다.
  - 문제: 포커스 속성을 줘도 동작되지 않는 문제가 있었습니다.
  - 해결: 입력값이 한글자 바뀌었을 때 호출되는 Delegate 메소드가 세부적인 타이밍 별로 여러개가 있었고, 이를 숙지하여 요구사항에 맞는 메소드를 사용했습니다.
  
</br>

### 2. Kakao & Naver Login 정보로 Firebase 인증하기
  - 상황: Firebase Auth에서 인증정보를 지원하지 않는 소셜로그인은 커스텀토큰을 발급하여 로그인을 할 수 있습니다.
  - 문제: Firebase Auth SDK에서 커스텀 토큰 발급을 지원하지 않아서 프로젝트 내에서 구현할 수 없었습니다.
  - 해결: git에 올라온 node.js 오픈 소스를 활용해 로컬서버를 일시적으로 돌려 테스트할 수 있었습니다.
  
  
</br>


## 리펙토링
### 1. 의존성 주입
- 생성자에서 클래스 인스턴스를 선언할때 최대한 추상화 객체인 프로토콜에 의존하도록 했습니다.
- 하나의 클래스에 담긴 기능도 역할에 따라 여러 프로토콜로 정의했습니다.
- StoryBoard로 작성된 ViewController로 화면전환할 때에도 초기화 메소드에 인자를 전달할 수 있다는 것을 알았습니다.
  
</br>

### 2. Completion handler -> Async/Await
- 기존 코드에선 직접 네트워크 통신하는 메소드는 async 키워드를 사용하여 작성했으나, Firebase나 소셜로그인 SDK 내부 메소드는 모두 컴플리션 핸들러로 작성했습니다.
- async 메소드 사용을 위해 중간에 Task 블럭이 추가되면서 안쓰느니만 못하게 블럭이 깊어지는 문제가 있었습니다.
    <details>
    <summary><b>기존 코드</b></summary>
    <div markdown="1">
    
    ~~~Swift
    //SocialLogin.swift
      //MARK: kakao 로그인
      func kakaoLogin(isLogin: Bool, completionHandler: @escaping ((Bool) -> Void)){
          //accessToken 요청
          self.requestKakaoToken(){accessToken in
              ...
              //회원정보 조회
              UserApi.shared.me(){ (user, error) in
                  //회원 여부 확인
                  ...
                  Task(priority: .userInitiated){
                      do{
                          //db에서 회원 여부 확인
                          if (try await self.dbNetworkManager?.selectWhereEmail(email: userEmail)?.filter({$0.value.id.rawValue == loginType.kakao.rawValue}).keys.first) == nil{
                            ...
                          }

                          //로컬서버에서 토큰 발급
                          guard let customToken = try await self.serverNetworkManager?.requestToken(accessToken: accessToken!) else {return}

                          //로그인
                          self.firebaseLogin?.customLogin(customToken: customToken){result in
                              if result{
                                  completionHandler(true)
                              }
                          }
                        }
                  }
              }
          }
      }
    ~~~
      
    </div>
    </details>
    
- async SDK 메소드를 사용하고, 일부 지원되지 않는 메소드를 사용해야 할 때는 withCheckedThrowingContinuation() 메소드를 사용하여 클로저를 async로 덮고 메소드를 분리했습니다.
    <details>
    <summary><b>수정 코드</b></summary>
    <div markdown="1">
    
    ~~~Swift
    //SocialLogin.swift
      func kakaoLogin(isLogin: Bool) async throws{
        //accessToken 요청
        let accessToken = try await requestKakaoToken()
        //회원정보 조회
        let kakaoAccount = try await requestKakaoAccount()
        
        //db에서 회원 여부 확인
        if (try await self.dbNetworkManager?.selectWhereEmail(email: userEmail)?.filter({$0.value.id == loginType.kakao.rawValue}).keys.first) == nil{
          ...
        }
        //회원가입 정보가 있음
        if !isLogin{
            throw LoginError.foundJoinData(key: "카카오 계정")
        }

        //로컬서버에서 토큰 발급
        guard let customToken = try await self.serverNetworkManager?.requestToken(loginType: loginType.kakao, accessToken: accessToken) else {return}

        //로그인
        try await self.firebaseLogin?.customLogin(customToken: customToken)
    }
    ~~~
    
    ~~~Swift
    //SocialLogin.swift
        internal func requestKakaoAccount() async throws -> Account?{
        return try await withCheckedThrowingContinuation{continuation in
            UserApi.shared.me(){ (user, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: user?.kakaoAccount)
            }
        }
    }
    ~~~
      
    </div>
    </details>
    
</br>

### 3. 예외처리 & LocalizedError
- 오류를 마지막 단에서 한꺼번에 처리하기위해 Throw 키워드를 사용하고, 반복되는 오류메시지를 분류해 열거형으로 정의했습니다.
- 기존코드에서 error.localizedDescription으로 표시하고 있었기 때문에 LocalizedError 프로토콜을 준수하도록 작성했습니다.
    <details>
    <summary><b>코드</b></summary>
    <div markdown="1">
    
    ~~~Swift
    //  LoginError.swift
      extension LoginError:  LocalizedError{
          public var errorDescription: String?{
              switch self{
              case .nilData(key: let key):
                  return NSLocalizedString("\(key) 값이 없습니다.", comment: "")
              case .discrepancyData(key: let key):
                  return NSLocalizedString("\(key) 값이 일치하지 않습니다.", comment: "")
              case .notFoundLoginData:
                  return NSLocalizedString("아이디 또는 비밀번호가 일치하지 않습니다.", comment: "")
              case .notFoundSocialJoinData(key: let key):
                  return NSLocalizedString("\(key) 계정으로 가입 된 정보가 없습니다.", comment: "")
              case .foundJoinData(key: let key):
                  return NSLocalizedString("이미 가입된 \(key) 입니다.", comment: "")
              case .notInstalledApp(key: let key):
                  return NSLocalizedString("\(key)이 설치되지 않았습니다.", comment: "")
              case .requestAgain(key: let key):
                  return NSLocalizedString(key, comment: "")
              }
          }
      }
    ~~~
      
    </div>
    </details>


</br>


## 기타
### Kakao iOS SDK 버그 제보
- 카카오톡으로 로그인하기를 구현하면서 API호출을 했을 때 원하는 결과값이 나오지 않았습니다.
- SDK 내부 코드를 확인해보니 파라메터로 받아온 값을 내부에서 호출하는 메소드에 태우지 않고있었습니다.
- 이부분을 Dev Talk에 문의하였고 잘못된 응답이 맞다는 답변과 최신 버전(iOS SDK 2.15.0)에서 수정되었다는 답변을 받았습니다.
- 이후 SDK를 업데이트하고 정상동작까지 확인하였습니다.
