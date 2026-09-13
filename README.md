# HALANQI Real Menu v2 — Phone Build

نسخة Theos مع إصلاح التقاط `-init` وإضافة GitHub Actions للبناء من الجوال.

## البناء من الجوال — الطريقة الأسهل
1. نزّل ZIP وفك الضغط.
2. افتح GitHub من Safari أو تطبيق GitHub.
3. أنشئ Repository جديد باسم `HALANQI`.
4. ارفع **كل محتويات** هذا المجلد إلى الـRepository، وليس ملف ZIP نفسه.
5. ادخل: **Actions → Build HALANQI → Run workflow**.
6. بعد انتهاء البناء: افتح الـworkflow ثم **Artifacts → HALANQI-package**.
7. ستحصل على ملف `.deb`.

الـworkflow يستخدم macOS runner، لذلك لا تحتاج تثبيت WSL أو Theos على الآيفون.

## ملاحظات
- المشروع لا يحتوي على وظائف Bots.
- المشروع مستقل؛ لا ينسخ كود SharkMod.
- يحتاج جهاز/بيئة jailbreak مناسبة لتثبيت وتشغيل tweak؛ ملف `.deb` الناتج ليس تطبيق IPA مستقلاً.
- إذا فشل الـworkflow، افتح سجل **Build package** وأرسل لي صورة الخطأ.
