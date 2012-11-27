FasdUAS 1.101.10   ��   ��    k             l     ��  ��      mergeVideoAndAudio     � 	 	 &   m e r g e V i d e o A n d A u d i o   
  
 l     ��  ��    U O script to merge sermon video and audio for the walnut street church of christ      �   �   s c r i p t   t o   m e r g e   s e r m o n   v i d e o   a n d   a u d i o   f o r   t h e   w a l n u t   s t r e e t   c h u r c h   o f   c h r i s t        l     ��  ��      presentation suite     �   &   p r e s e n t a t i o n   s u i t e      l     ��  ��      Author: Todd Jobe     �   $   A u t h o r :   T o d d   J o b e      l     ��  ��      Date: 2012-11-28     �   "   D a t e :   2 0 1 2 - 1 1 - 2 8      l     ��   !��     1 + TODO: Add support for multiple input files    ! � " " V   T O D O :   A d d   s u p p o r t   f o r   m u l t i p l e   i n p u t   f i l e s   # $ # l     ��������  ��  ��   $  % & % l     �� ' (��   '  --------------    ( � ) )  - - - - - - - - - - - - - - &  * + * l     �� , -��   ,  	 settings    - � . .    s e t t i n g s +  / 0 / l     �� 1 2��   1  --------------    2 � 3 3  - - - - - - - - - - - - - - 0  4 5 4 l     �� 6 7��   6 ? 9 starting directory for the video files, should be shared    7 � 8 8 r   s t a r t i n g   d i r e c t o r y   f o r   t h e   v i d e o   f i l e s ,   s h o u l d   b e   s h a r e d 5  9 : 9 l     ;���� ; r      < = < m      > > � ? ? 4 M a c i n t o s h   H D : U s e r s : s u n r a e s = o      ���� (0 videofiledirectory videoFileDirectory��  ��   :  @ A @ l     ��������  ��  ��   A  B C B l     �� D E��   D 9 3 starting directory for the audio files, not shared    E � F F f   s t a r t i n g   d i r e c t o r y   f o r   t h e   a u d i o   f i l e s ,   n o t   s h a r e d C  G H G l    I���� I r     J K J m     L L � M M 4 M a c i n t o s h   H D : U s e r s : s u n r a e s K o      ���� (0 audiofiledirectory audioFileDirectory��  ��   H  N O N l     ��������  ��  ��   O  P Q P l     �� R S��   R E ? starting directory for the final combined video and audio file    S � T T ~   s t a r t i n g   d i r e c t o r y   f o r   t h e   f i n a l   c o m b i n e d   v i d e o   a n d   a u d i o   f i l e Q  U V U l    W���� W r     X Y X m    	 Z Z � [ [ D M a c i n t o s h   H D : U s e r s : s u n r a e s : D e s k t o p Y o      ���� 40 outputvideofiledirectory outputVideoFileDirectory��  ��   V  \ ] \ l     ��������  ��  ��   ]  ^ _ ^ l     �� ` a��   ` G A maximum time difference between the start of the audio and video    a � b b �   m a x i m u m   t i m e   d i f f e r e n c e   b e t w e e n   t h e   s t a r t   o f   t h e   a u d i o   a n d   v i d e o _  c d c l    e���� e r     f g f m    ���� 
 g o      ���� 0 maxdiff maxDiff��  ��   d  h i h l     ��������  ��  ��   i  j k j l     �� l m��   l  	---------    m � n n  - - - - - - - - - k  o p o l     �� q r��   q   user input    r � s s    u s e r   i n p u t p  t u t l     �� v w��   v  	---------    w � x x  - - - - - - - - - u  y z y l     ��������  ��  ��   z  { | { l     �� } ~��   }   select the video file    ~ �   ,   s e l e c t   t h e   v i d e o   f i l e |  � � � l   $ ����� � r    $ � � � I    ���� �
�� .sysostdfalis    ��� null��   � �� � �
�� 
prmp � m     � � � � � < S t e p   1   o f   4 :   C h o o s e   v i d e o   f i l e � �� � �
�� 
ftyp � J     � �  ��� � m     � � � � �  m p 4��   � �� ���
�� 
dflc � 4    �� �
�� 
alis � o    ���� (0 videofiledirectory videoFileDirectory��   � o      ���� 0 	videofile 	videoFile��  ��   �  � � � l     ��������  ��  ��   �  � � � l     �� � ���   �   select the audio file    � � � � ,   s e l e c t   t h e   a u d i o   f i l e �  � � � l  % @ ����� � r   % @ � � � I  % <���� �
�� .sysostdfalis    ��� null��   � �� � �
�� 
prmp � m   ' * � � � � � < S t e p   2   o f   4 :   C h o o s e   a u d i o   f i l e � �� � �
�� 
ftyp � J   + 3 � �  � � � m   + . � � � � �  w a v �  ��� � m   . 1 � � � � �  m p 3��   � �� ���
�� 
dflc � 4   4 8�� �
�� 
alis � o   6 7���� (0 audiofiledirectory audioFileDirectory��   � o      ���� 0 	audiofile 	audioFile��  ��   �  � � � l     ��������  ��  ��   �  � � � l     �� � ���   � = 7 use ffprobe to get the comment tag from the video file    � � � � n   u s e   f f p r o b e   t o   g e t   t h e   c o m m e n t   t a g   f r o m   t h e   v i d e o   f i l e �  � � � l     �� � ���   � L F this tag holds the date, and it's converted to be mac date compatible    � � � � �   t h i s   t a g   h o l d s   t h e   d a t e ,   a n d   i t ' s   c o n v e r t e d   t o   b e   m a c   d a t e   c o m p a t i b l e �  � � � l  A X ����� � r   A X � � � b   A T � � � b   A P � � � m   A D � � � � � t / u s r / l o c a l / b i n / f f p r o b e   - s h o w _ f o r m a t   - p r i n t _ f o r m a t   c o m p a c t   � l  D O ����� � n   D O � � � 1   K O��
�� 
strq � n   D K � � � 1   G K��
�� 
psxp � o   D G���� 0 	videofile 	videoFile��  ��   � m   P S � � � � �     |   s e d   ' s / . * t a g : c o m m e n t = \ ( [ T 0 - 9 ] * \ ) / \ 1 / '   |   x a r g s   - I   { }   d a t e   - j   - f   ' % Y % m % d T % H % M % S '   { }   + ' % A ,   % B   % d ,   % Y   % l : % M : % S   % p '   |   s e d   ' s /     /   / g ' � o      ���� 0 cmd  ��  ��   �  � � � l     ��������  ��  ��   �  � � � l  Y d ����� � r   Y d � � � I  Y `�� ���
�� .sysoexecTEXT���     TEXT � o   Y \���� 0 cmd  ��   � o      ���� 0 	videotime 	videoTime��  ��   �  � � � l  e q ����� � r   e q � � � 4   e m�� �
�� 
ldt  � l  i l ����� � o   i l���� 0 	videotime 	videoTime��  ��   � o      ���� 0 	videotime 	videoTime��  ��   �  � � � l     ��������  ��  ��   �  � � � l     �� � ���   � R L if there was no comment tag, then the user must enter the video start time.    � � � � �   i f   t h e r e   w a s   n o   c o m m e n t   t a g ,   t h e n   t h e   u s e r   m u s t   e n t e r   t h e   v i d e o   s t a r t   t i m e . �  � � � l  r � ����� � Z   r � � ����� � =   r } � � � c   r y � � � o   r u���� 0 	videotime 	videoTime � m   u x��
�� 
TEXT � m   y | � � � � �   � r   � � � � � n   � � � � � 1   � ���
�� 
ttxt � l  � � ����� � I  � ��� � �
�� .sysodlogaskr        TEXT � m   � � � � � � � : S t e p   5   o f   5 :   V i d e o   s t a r t   t i m e � �� � �
�� 
dtxt � n   � � � � � 1   � ���
�� 
tstr � l  � � ����� � I  � �������
�� .misccurdldt    ��� null��  ��  ��  ��   � �� � �
�� 
btns � J   � � � �  �  � m   � � �  c a n c e l  � m   � � �  n e x t�   � �~
�~ 
dflt m   � ��}�}  �|	
�| 
cbtn m   � ��{�{ 	 �z

�z 
appr
 m   � � � * M e r g e   V i d e o   a n d   A u d i o �y�x
�y 
givu m   � ��w�w d�x  ��  ��   � o      �v�v 0 	videotime 	videoTime��  ��  ��  ��   �  l     �u�t�s�u  �t  �s    l     �r�r   + % user must enter the audio start time    � J   u s e r   m u s t   e n t e r   t h e   a u d i o   s t a r t   t i m e  l  � ��q�p r   � � n   � � 1   � ��o
�o 
ttxt l  � ��n�m I  � ��l
�l .sysodlogaskr        TEXT m   � �   �!! : S t e p   3   o f   4 :   A u d i o   s t a r t   t i m e �k"#
�k 
dtxt" n   � �$%$ 1   � ��j
�j 
tstr% o   � ��i�i 0 	videotime 	videoTime# �h&'
�h 
btns& J   � �(( )*) m   � �++ �,,  c a n c e l* -�g- m   � �.. �//  n e x t�g  ' �f01
�f 
dflt0 m   � ��e�e 1 �d23
�d 
cbtn2 m   � ��c�c 3 �b45
�b 
appr4 m   � �66 �77 * M e r g e   V i d e o   a n d   A u d i o5 �a8�`
�a 
givu8 m   � ��_�_ d�`  �n  �m   o      �^�^ 0 	audiotime 	audioTime�q  �p   9:9 l  �;�]�\; r   �<=< 4   ��[>
�[ 
ldt > l  ?�Z�Y? b   @A@ b   BCB l  D�X�WD n   EFE 1  �V
�V 
dstrF o   �U�U 0 	videotime 	videoTime�X  �W  C m  
GG �HH   A o  �T�T 0 	audiotime 	audioTime�Z  �Y  = o      �S�S 0 	audiotime 	audioTime�]  �\  : IJI l  K�R�QK I  �PL�O
�P .sysodlogaskr        TEXTL c  MNM o  �N�N 0 	audiotime 	audioTimeN m  �M
�M 
TEXT�O  �R  �Q  J OPO l     �L�K�J�L  �K  �J  P QRQ l     �IST�I  S J D the default output name will be the same as the audio file, I guess   T �UU �   t h e   d e f a u l t   o u t p u t   n a m e   w i l l   b e   t h e   s a m e   a s   t h e   a u d i o   f i l e ,   I   g u e s sR VWV l !UX�H�GX r  !UYZY I !Q�F�E[
�F .sysonwflfile    ��� null�E  [ �D\]
�D 
prmt\ m  %(^^ �__ P S t e p   4   o f   4 :   C h o o s e   a n   o u t p u t   v i d e o   f i l e] �C`a
�C 
dfnm` l +Hb�B�Ab c  +Hcdc n  +Defe 76D�@gh
�@ 
cha g m  <>�?�? h m  ?C�>�>��f l +6i�=�<i n  +6jkj 1  26�;
�; 
pnamk l +2l�:�9l I +2�8m�7
�8 .sysonfo4asfe        filem o  +.�6�6 0 	audiofile 	audioFile�7  �:  �9  �=  �<  d m  DG�5
�5 
TEXT�B  �A  a �4n�3
�4 
dflcn 4  IM�2o
�2 
aliso o  KL�1�1 40 outputvideofiledirectory outputVideoFileDirectory�3  Z o      �0�0 0 
outputfile 
outputFile�H  �G  W pqp l     �/rs�/  r  -----------   s �tt  - - - - - - - - - - -q uvu l     �.wx�.  w  
 algorithm   x �yy    a l g o r i t h mv z{z l     �-|}�-  |  -----------   } �~~  - - - - - - - - - - -{ � l     �,���,  � !  calculate the video offset   � ��� 6   c a l c u l a t e   t h e   v i d e o   o f f s e t� ��� l Va��+�*� r  Va��� \  V]��� o  VY�)�) 0 	audiotime 	audioTime� o  Y\�(�( 0 	videotime 	videoTime� o      �'�' 0 	itsoffset  �+  �*  � ��� l     �&�%�$�&  �%  �$  � ��� l b{��#�"� Z  b{���!�� ?  bg��� o  be� �  0 	itsoffset  � o  ef�� 0 maxdiff maxDiff� r  js��� \  jo��� o  jm�� 0 	itsoffset  � o  mn�� 0 maxdiff maxDiff� o      �� 0 ss  �!  � r  v{��� m  vw��  � o      �� 0 ss  �#  �"  � ��� l     ����  �  �  � ��� l     ����  �   debug the final command   � ��� 0   d e b u g   t h e   f i n a l   c o m m a n d� ��� l |����� r  |���� b  |���� b  |���� b  |���� b  |���� b  |���� b  |���� b  |���� b  |���� b  |���� m  |�� ��� 2 / u s r / l o c a l / b i n / f f m p e g   - i  � l ����� n  ���� 1  ���
� 
strq� n  ���� 1  ���
� 
psxp� o  ��� 0 	videofile 	videoFile�  �  � m  ���� ���    - i t s o f f s e t  � o  ���� 0 	itsoffset  � m  ���� ���    - i  � l ������ n  ����� 1  ���
� 
strq� n  ����� 1  ���

�
 
psxp� o  ���	�	 0 	audiofile 	audioFile�  �  � m  ���� ��� 
   - s s  � o  ���� 0 ss  � m  ���� ���   � l ������ n  ����� 1  ���
� 
strq� l ������ b  ����� n  ����� 1  ���
� 
psxp� o  ���� 0 
outputfile 
outputFile� m  ���� ���  . m p 4�  �  �  �  � o      � �  0 
convertcmd 
convertCmd�  �  � ��� l     ������  � % set the clipboard to convertCmd   � ��� > s e t   t h e   c l i p b o a r d   t o   c o n v e r t C m d� ��� l �������� I �������
�� .sysoexecTEXT���     TEXT� o  ������ 0 
convertcmd 
convertCmd��  ��  ��  � ���� l �������� I �������
�� .sysodlogaskr        TEXT� m  ���� ���  d o n e��  ��  ��  ��       ������  � ��
�� .aevtoappnull  �   � ****� �����������
�� .aevtoappnull  �   � ****� k    ���  9��  G��  U��  c��  ���  ���  ���  ���  ���  ��� �� 9�� I�� V�� ��� ��� ��� ��� �����  ��  ��  �  � I >�� L�� Z�������� ��� ����������� � � ��� ����� ����������� � ������������������������� +.6����G��^����������������������������� (0 videofiledirectory videoFileDirectory�� (0 audiofiledirectory audioFileDirectory�� 40 outputvideofiledirectory outputVideoFileDirectory�� 
�� 0 maxdiff maxDiff
�� 
prmp
�� 
ftyp
�� 
dflc
�� 
alis�� 
�� .sysostdfalis    ��� null�� 0 	videofile 	videoFile�� 0 	audiofile 	audioFile
�� 
psxp
�� 
strq�� 0 cmd  
�� .sysoexecTEXT���     TEXT�� 0 	videotime 	videoTime
�� 
ldt 
�� 
TEXT
�� 
dtxt
�� .misccurdldt    ��� null
�� 
tstr
�� 
btns
�� 
dflt
�� 
cbtn
�� 
appr
�� 
givu�� d�� 
�� .sysodlogaskr        TEXT
�� 
ttxt�� 0 	audiotime 	audioTime
�� 
dstr
�� 
prmt
�� 
dfnm
�� .sysonfo4asfe        file
�� 
pnam
�� 
cha ����
�� .sysonwflfile    ��� null�� 0 
outputfile 
outputFile�� 0 	itsoffset  �� 0 ss  �� 0 
convertcmd 
convertCmd����E�O�E�O�E�O�E�O*����kv�*��/� E` O*�a �a a lv�*��/� E` Oa _ a ,a ,%a %E` O_ j E` O*a _ /E` O_ a &a   Aa a  *j !a ",a #a $a %lva &la 'ka (a )a *a +a , -a .,E` Y hOa /a  _ a ",a #a 0a 1lva &la 'ka (a 2a *a +a , -a .,E` 3O*a _ a 4,a 5%_ 3%/E` 3O_ 3a &j -O*a 6a 7a 8_ j 9a :,[a ;\[Zk\Za <2a &�*��/� =E` >O_ 3_ E` ?O_ ?� _ ?�E` @Y jE` @Oa A_ a ,a ,%a B%_ ?%a C%_ a ,a ,%a D%_ @%a E%_ >a ,a F%a ,%E` GO_ Gj Oa Hj - ascr  ��ޭ