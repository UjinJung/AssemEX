.Test입니다

..Ver1.2
...추가 사항
....STRSAM에서 Indirect Addressing 삭제
....주석 추가
...문제점
....그냥 frequency 줘서 Start버튼 눌러서 실행 시 숫자 입력이 제대로 되지 않는 듯 함. chk요망

..........Ver1.3.................

...추가 사항...
....깜박하고 안적어서;
....우선 Input 받은 거 Print까지 완료

...문제점...
....여전히 frequency를 주어야 정상 작동한다.
....미리 값을 입력해놓으면 정상 작동하지만 멈춘 뒤 입력하려고 하면 불가능하다.
....계속 알아볼 것.

TEST	START	0
FIRST	JSUB	INSAMP
	JSUB	INSERT
	END	TEST









....................Input Processing........................
INSAMP	CLEAR	X
	CLEAR	A
	LDT	#5
INPMSG	LDA	#IMSLEN
	SUB	#IMSTXT
	STA	IMSLEN
IMSPRT	LDA	IMSTXT, X
	WD	OUTDEV
	TIX	IMSLEN
	JLT	IMSPRT
	CLEAR	A
	CLEAR	X
INLOOP	TD	INDEV
	JEQ	INLOOP
	RD	INDEV
	COMP	#69	.'E' EOF 체크를 위해서 비교
	JEQ	EOFCHK
	COMP	#32	.공백을 나타내는 아스키값
	JEQ	ENDFIL
	COMP	#0
	JEQ	INLOOP
.여기서 너무 길면 체크해줘야 할 거 같은데;
.LDS	#10
.COMP	X, S
.이런거라도 해줘야 하지 않을까..?
	COMP	#48	.'0' 보다 작으면 JUNK처리
	JLT	JUNK
	COMP	#57	.'9' 보다 크면 JUNK처리
	JGT	JUNK
	SUB	#48	.아스키 값을 10진수로 변경
	CLEAR	S
	ADDR	A, S	.S에 A값(읽어온 값)을 옮겨놓음
	CLEAR	A	.A 초기화
	.COMPR	A, X
	.JEQ	STRTMP
	.LDA	TMPNUM
	.SHIFTL	A, 8 
	.STA	TMPNUM

.STRTMP
..A에 TMPNUM 예전꺼 집어넣고 10곱해줘서 자릿수 맞추어줌
...6자리 넘어갈 경우 JUNK처리하고 버림
....그리고 S에 있던 이번에 읽어온 값을 1의 자리에 넣어주는 형식
STRTMP	LDA	TMPNUM
	.MULR	A, S
	.LDA	TMPNUM
	MUL	#10
	ADDR	S, A
	TIXR	T	.6자리 이상이면 JUNK처리
	JGT	INLOOP
	STA	TMPNUM
	CLEAR	A
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
ENDFIL	CLEAR	A
	.STA	MULDIG
	LDA	JUKCHK	.Junk인지 check
	COMP	#1
	JEQ	CLERDY	.Junk면 다 폐기
	CLEAR	A
	.ADDR	X, A
	.STA	INPLEN
	.LDA	#3
	.SUBR	X, A
	.STA	NUMADD
	LDA	#3	.시작주소 계산을 위해서
	MUL	INPNUM	.INPut NUMber 는 0부터 시작하며 Input의 개수를 나타낸다.
	.SUB	#3
	.STA	STAADD
	.LDX	STAADD
	.CLEAR	A
.ZERFIL	STA	STR1, X
.	TIX	NUMADD
.	JLT	ZERFIL
.INDEX + 주소값
	.LDA	STAADD	
	.ADD	NUMADD
	.LDS	#STR1	.변수 시작 주소를 더해줍니다.
	.ADDR	S, A
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
	..	
	..STA	@STAADD

	.TIX	INPLEN
	.LDA	NUMADD
	.ADD	#1
	.STA	NUMADD
	.JLT	STRSAM
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
	LDA	#3
	MUL	INPNUM
	STA	INPLEN
	JEQ	ENDINP
	J	CLERDY

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
ENDINP	LDA	#0
	STA	TMPNUM
	STA	FIGURE
	LDA	#100
	STA	FIGURE
	LDA	#STR1
	STA	NUMADD
	..X는 input 개수 chk해야되니까 indirect로
	.MULR	A, X
	.LDA	STR1, X
	LDA	#3
	MULR	X, A
	ADD	NUMADD
	STA	NUMADD
	LDA	@NUMADD
	STA	TMPNUM
	CLEAR	S
	LDA	#32
	WD	OUTDEV
CALFIG	LDA	TMPNUM
	DIV	FIGURE
	COMP	#0
	JEQ	JZERO
	CLEAR	T
	CLEAR	S
	ADDR	A, T
	MUL	FIGURE
	ADDR	A, S
	LDA	TMPNUM
	SUBR	S, A
	STA	TMPNUM
	CLEAR	A
	ADDR	T, A
	ADD	#48
	WD	OUTDEV
JZERO	LDA	FIGURE
	DIV	#10
	STA	FIGURE
	COMP	#0
	JGT	CALFIG
	TIX	INPNUM
	JLT	ENDINP
	RSUB	

ZERO	WORD	0		.ZERO 필요없지 않나?
STAADD	RESW	1		.각 SAMPLE Input 시작 주소 Index값
NUMADD	RESW	1		.각 SAMPLE Input 숫자 시작 주소 Index값
				.ver1.3 출력용 indirect 주소저장소로 사
INPLEN	RESW	1		.각 SAMPLE 숫자 길이
INPNUM	WORD	0		.각 SAMPLE Input 개수
TMPNUM	RESW	1		.숫자를 임시로 저장해둔다.
.MULDIG	WORD	1
JUKCHK	WORD	0		.Junk인지 chk하기 위한 변수 (0 = not junk, 1 = junk)
STR1	RESW	1		.배열 시작
STR2	RESW	1
STR3	RESW	1
STR4	RESW	1
STR5	RESW	1
STR6	RESW	1
STR7	RESW	1
STR8	RESW	1
STR9	RESW	1
STR10	RESW	1
STR11	RESW	1
STR12	RESW	1
STR13	RESW	1
STR14	RESW	1
STR15	RESW	1
FIGURE	WORD	100
INDEV	BYTE	X'00'
OUTDEV	BYTE	X'01'
.MULNUM	BYTE	X'10'


IMSTXT	BYTE	C'  Input을 입력해주세요.(3자리까지 가능합니다)'		.Input MaSsage Text
	BYTE	10
	BYTE	C'형식 : num num num num num EOF'
	BYTE	10
	.BYTE	C'(띄어쓰기로 구분해주시면 되고 15개까지 가능하며 끝은 EOF로 표시합니다)'
	.BYTE	10
IMSLEN	RESW	1
