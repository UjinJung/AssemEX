
BUBSOT	START	0
FIRST	JSUB	INSAMP	.Input



....................Insertion Sorting Ready............................

BUBMSG	LDA	#10
	WD	OUTDEV
	WD	OUTDEV
	CLEAR	X
	LDA	#BUBLEN
	SUB	#BUBTXT
	STA	BUBLEN
BUBPRT	LDA	BUBTXT,	X	
	WD	OUTDEV
	TIX	BUBLEN
	JLT	BUBPRT	
	JSUB	BUBRDY


....................END........................
	END	BUBSOT	
EXIT	J	EXITTW	
EXITTW	J	EXIT
...............................................

....................Input Processing........................
.Input Msg 출력
INSAMP	CLEAR	X
	LDT	#5
INPMSG	LDA	#10	
	WD	OUTDEV
	TIX	#25
	JLT	INPMSG
	CLEAR	X
	LDA	#IMSLEN
	SUB	#IMSTXT
	STA	IMSLEN
IMSPRT	LDA	IMSTXT, X
	WD	OUTDEV
	TIX	IMSLEN
	JLT	IMSPRT
	CLEAR	X
.#ZERO	~ #FIGURE CLEAR
	LDA	#0
	STA	IMSLEN
CLENUM	CLEAR	A
	STA	@IMSLEN
	LDA	#3
	ADD	IMSLEN
	STA	IMSLEN
	COMP	#STRLEN
	JLT	CLENUM
	CLEAR	A	

.INput LOOP
..Input을 받아옵니다.
INLOOP	TD	#0
	JEQ	INLOOP
	RD	#0
	COMP	#69	.'E' EOF 체크를 위해서 비교
	JEQ	EOFCHK
	COMP	#32	.공백을 나타내는 아스키값
	JEQ	ENDFIL
	COMP	#0
	JEQ	INLOOP
	COMP	#48	.'0' 보다 작으면 JUNK처리
	JLT	JUNK
	COMP	#57	.'9' 보다 크면 JUNK처리
	JGT	JUNK
	SUB	#48	.아스키 값을 10진수로 변경
	CLEAR	S
	ADDR	A, S	.S에 A값(읽어온 값)을 옮겨놓음
	CLEAR	A	.A 초기화

.STRTMP
..A에 TMPNUM 예전꺼 집어넣고 10곱해줘서 자릿수 맞추어준다.
...6자리 넘어갈 경우 JUNK처리하고 버림
....그리고 S에 있던 이번에 읽어온 값을 1의 자리에 넣어주는 형식
STRTMP	LDA	TMPNUM
	MUL	#10
	ADDR	S, A
	TIXR	T	.6자리 이상이면 JUNK처리
	JGT	INLOOP
	STA	TMPNUM
	CLEAR	A
	STA	JUKCHK
	J	INLOOP

.JUNK
..JUNK는 Junk Check 변수에 값을 1로 해주고 junk임을 표시해 준다.
...그리고 해당하는 곳의 값을 다 제거해줘야되니까 띄어쓰기가 나올 때까지 Loop를 돌린다.
JUNK	LDA	#1
	STA	JUKCHK
	J	INLOOP

.ENDFIL
..공백을 만나게 되면 ENDFIL로 이동된다.
...Junk일 경우 Clear Ready로 이동하여 TempNum을 비워준다.
....1줄씩 옮겨가려면 3byte를 이동해야해서 3에 input 숫자를 곱해준다.(0부터 시작; 0 = 1개, 1 = 2개)
.....STArt ADDress에 첫번째 변수의 주소를 immediate addressing 을 통해 더해준다.
.ENDFIL	CLEAR	A
ENDFIL	LDA	JUKCHK	.Junk인지 check
	COMP	#1
	JEQ	CLERDY	.Junk면 다 폐기
	CLEAR	A
	LDA	#3	.시작주소 계산을 위해서
	MUL	INPNUM	.INPut NUMber 는 0부터 시작하며 Input의 개수를 나타낸다.
	STA	STAADD
.숫자 저장
	CLEAR	X

.STRSAM
..SToRe SAMple 은 Temp Number에 임시로 저장해 두었던 값을 배열?에 차례대로 정리해줍니다.
...끝나고 INPut NUMber를 1증가 시켜준다.
....최대로 받을 수 있는 숫자의 개수는 15개로 한정하고 15개가 넘어가면 값을 받아오는 것을 종료한다.
.....그렇지 않으면 CLEar ReaDY로 이동해서 Temp Number를 초기화한다.
STRSAM	LDA	TMPNUM
	..그냥 Index로 해도 될 듯
	...처음에는 Indirect로 하려고 했으나 그렇게까지 할 필요가..?
	LDX	STAADD
	STA	STR1, X
	LDA	INPNUM
	ADD	#1	.Input Number 1 증가
	STA	INPNUM
	COMP	#15	.Sample의 숫자가 15개가 넘어가면 종료한다.
	JGT	ENDINP
	CLEAR	S
	J	CLERDY

.EOFCHK
..EOF CHecK 는 byte단위로 READ를 진행 중 'E'가 발견되었을 시에 이동되어 EOF를 체크한다.

...EOF가 아닐 경우 공백을 만날 때까지 빼주어야하는 데 그건 좀 생각해보자.
EOFCHK	RD	#0
	COMP	#79
	JEQ	EOFCHK
	COMP	#70
	CLEAR	A
	CLEAR	X
	JEQ	ENDINP

.CLERDY
..CLEar ReaDY는 Temp Number를 초기화하기 전 준비 단계이다.
CLERDY	CLEAR	A
	CLEAR	X
	CLEAR 	S

.CLETMP
..CLEar TeMP 는 Temp Number를 초기화 해서 재사용하게 만든다. 
CLETMP	STA	TMPNUM, X
	TIX	#3
	JLT	CLETMP
	CLEAR	X
	JEQ	INLOOP	

.EXITLP
..EXIT LOOP는 현재 숫자 받아오는 것이 끝난 상태이며 임시로 저장해놓은 이름이고 바뀔 수도 있다.
...RSUB 추가 예정 ver1.1
...RSUB 추가 ver1.3
...Print로 이름 바꿀 수도 ver1.4
ENDINP	LDA	#100
	STA	FIGURE
	LDA	#0
	STA	TMPNUM
	STA	FIGURE	.FIGURE, TMPNUM 초기화
	LDA	#100	.자릿수 조절을 위해 FIGURE에 100 추가 최대 3자리.
	STA	FIGURE
	LDA	#STR1	
	STA	NUMADD	.STR1 주소 불러와서 NUMADD에 저장
	..X는 input 개수 chk해야되니까 indirect로
	LDA	#3	
	MULR	X, A	.X는 몇번째 Sample인지 나타내고 3을 곱해주어서 해당 주소로 이동하게 한다.
	ADD	NUMADD
	STA	NUMADD
	LDA	@NUMADD	.해당 되는 주소의 값을 불러온다.
	STA	TMPNUM	.TMPNUM에 해당 값을 저장한 뒤 S reg 를 초기화한다.
	CLEAR	S
	LDA	#32	.띄어쓰기를 한번 한다. ver1.4 이거 수정할 수도 첫번째에 띄어쓰기 되어서;
	WD	OUTDEV	.쓰기
	LDA	NUMADD
	COMP	PIVIND
	JEQ	PIVMAK
	J	CALFIG
PIVMAK	LDA	#124
	WD	OUTDEV
	LDA	#32
	WD	OUTDEV
	LDA	#0
	STA	INPLEN
.CALFIG
..CALculate FIGure 는 자릿수를 계산해서 저장한 뒤 출력해준다.
CALFIG	CLEAR	T
	LDA	TMPNUM	.TMPNUM을 불러와서 현재 자릿수(Figure)로 나누어준다.
	DIV	FIGURE
	ADDR	A, T	.T reg에 A reg 값을 할당한다.(현재 A reg값은 해당 자릿수의 값이다)
	LDA	INPLEN
	COMP	#0
	JGT	PRTNUM
	CLEAR	A
	ADDR	T, A
	COMP	#0	.만약 0이면 해당 자릿수에 값이 없는 것이니 JZERO로 넘어간다.
	JEQ	JZERO
	STA	INPLEN
PRTNUM	CLEAR	S
	CLEAR	A
	ADDR	T, A
	MUL	FIGURE	.해당 자릿수의 값을 다시 곱해주어 200, 10, 40 이런 식으로 나타나게 한다.
	ADDR	A, S	.해당 값을 S reg에 할당한 뒤 TMPNUM값에서 빼주어 해당 자릿수를 없앤다.
	LDA	TMPNUM	
	SUBR	S, A
	STA	TMPNUM
	CLEAR	A	.A reg를 초기화 한뒤 T reg에 할당해 놓은 자릿수의 계수 값을 받아온다.
	ADDR	T, A	
	ADD	#48	.48을 더해주어 ASCII값으로 표현해 출력한다.
	WD	OUTDEV
.JZERO
..Jump Zero? 는.. 자릿수가 없으면 점프해 오는 곳이고 본 목적은 자릿수를 한자리 감소시키는 역할을 한다.
..감소 시킨 뒤 자릿수가 남았으면 CALFIG로 Jump하고
..안남았으면 X를 1 증가 시키고 Input Number보다 작으면 ENDINP로 Jump하고 아니면 루틴을 빠져나온다.
JZERO	LDA	FIGURE	
	DIV	#10
	STA	FIGURE
	COMP	#0 
	JGT	CALFIG
	TIX	INPNUM
	CLEAR	A
	STA	INPLEN
	JLT	ENDINP
	RSUB	

...................Bubble Sort Processing........................
....큰 LOOP
BUBRDY	CLEAR	A
	CLEAR	X
	LDA	INPNUM
	SUB	#1
	MUL	#3
	ADD	#STR1	.마지막으로 들어온 값 주소 계산
	STA	PIVIND	.마지막 주소값 PIVNUM에 저장
.처음값 저장
BUBBLE	LDA	#STR2	.Lable 필요할까?
	STA	TMPNXT
STEP	LDA	TMPNXT
	SUB	#3
	STA	TMPIND
	LDA	@TMPIND
	COMP	@TMPNXT
	.Index(A reg)가 크면 교환
	..3증가 시켰을 떄 TMPNXT 값이 PIVIND보다 크거나 TMPIND가 PIVIND랑 같을 때 빠져나와서
	..PIVIND를 3 줄여주고 BUBBLE로 이동해서 다시 시작
	...PIVIND를 3 줄였을 때 STR1이랑 같으면 빠져나옴
	JLT	NOCHAN	.교환 안해도 됨
	LDA	@TMPIND
	STA	TMPNUM
	LDA	@TMPNXT
	STA	@TMPIND
	LDA	TMPNUM
	STA	@TMPNXT
	.교환 안해도 됨
	.
NOCHAN	LDA	TMPNXT
	ADD	#3
	STA	TMPNXT
	COMP	PIVIND
	JEQ	STEP
	JLT	STEP
	
	CLEAR	A
	ADDR	L, A
	STA	RETADD
	LDA	#10
	WD	OUTDEV
	LDA	#91
	WD	OUTDEV
	CLEAR	X
	JSUB	ENDINP
	LDA	#32
	WD	OUTDEV
	LDA	#93
	WD	OUTDEV
	LDL	RETADD
	
	LDA	PIVIND
	SUB	#3
	STA	PIVIND
	COMP	#STR1
	JGT	BUBBLE	
	RSUB

.교환 후에 TMPNXT 3증가 후 PIVIND와 비교
.PIVIND보다 크지 않으면 BUBBLE로 이동해서 시작
.TMPNXT > PIVIND 이면 PIVIND 3감소
..PIVIND 3감소 후 STR1과 비교 후 같으면 끝
	

	
.ZERO	WORD	0	
STAADD	RESW	1	.각 SAMPLE Input 시작 주소 Index값
NUMADD	RESW	1	.각 SAMPLE Input 숫자 시작 주소 Index값
			.ver1.3 출력용 indirect 주소저장소로 사
ENDADD	RESW	1
INPLEN	RESW	1	.각 SAMPLE 숫자 길이
INPNUM	WORD	0	.각 SAMPLE Input 개수
TMPNUM	RESW	1	.숫자를 임시로 저장해둔다.
PIVIND	RESW	1	.PIVot INDex
PIVNUM	RESW	1
TMPIND	RESW	1
TMPNXT	RESW	1
JUKCHK	WORD	0	.Junk인지 chk하기 위한 변수 (0 = not junk, 1 = junk)
STR1	RESW	1	.배열 시작
STR2	RESW	1
	RESW	1
	RESW	1
	RESW	1
	RESW	1
	RESW	1
	RESW	1
	RESW	1
	RESW	1
	RESW	1
	RESW	1
	RESW	1
	RESW	1
	RESW	1
STRLEN	RESW	1
FIGURE	WORD	100
INDEV	BYTE	X'00'
OUTDEV	BYTE	X'01'
RETADD	RESW	1

IMSTXT	BYTE	C'  Input을 입력해주세요.(3자리까지 가능합니다)'		.Input MaSsage Text
	BYTE	10
	BYTE	C'형식 : num num num num num EOF'
	BYTE	10
	BYTE	C'(띄어쓰기로 구분해주시면 되고 15개까지 가능하며 끝은 EOF로 표시합니다)'
	BYTE	10
IMSLEN	RESW	1
BUBTXT	BYTE	C'  Bubble Sort'
	BYTE	10
BUBLEN	RESW	1
