# soulink

TODO
soulink 는 계약이 소유할 수도 있는가(멀티시그일수도 있고, 단순 계약일 수도 있고.) -> yes 라면 ECDSA.recover 가 아닌 SignatureCheck 를 사용해야함. no 라면 mint 시 isContract 체크 고려. 혹은 계약이 mint 가능하지만, link 는 안됨이라든지.

sbt는 재배정이 가능한가
(soulink 는 재배정 불가. burn 시 모든 기록 삭제.)