@echo off
set dest=%1
call xcopy cover-v2.pdf %dest%/00.pdf /y
call mdpdf 01_version.md %dest%/01.pdf --format=A5
call mdpdf 02_dedication.md %dest%/02.pdf --format=A5
call mdpdf 03_index.md %dest%/03.pdf --format=A5
call mdpdf 04_intro.md %dest%/04.pdf --format=A5
call mdpdf C1_freedom_mindset.md %dest%/10.pdf --format=A5
call mdpdf C2_slavery.md %dest%/20.pdf --format=A5
call mdpdf C3_leverage.md %dest%/30.pdf --format=A5
call mdpdf C4_recognizing_your_leverage.md %dest%/40.pdf --format=A5
call mdpdf C5_remove_obstacles.md %dest%/50.pdf --format=A5
call mdpdf C6_new_opportunities.md %dest%/60.pdf --format=A5
call mdpdf C7_communicating_optionality.md %dest%/70.pdf --format=A5
call mdpdf C8_freedom_hacks.md %dest%/80.pdf --format=A5
call mdpdf C9_let_freedom_reign.md %dest%/90.pdf --format=A5
call mdpdf X_A0_further_reading.md %dest%/92.pdf --format=A5
call mdpdf X_A1_case_study_1.md %dest%/95.pdf --format=A5
call mdpdf X_Z1_bio.md %dest%/96.pdf --format=A5

cd %dest%
call pdftk *.pdf cat output book/liberation-book.pdf
call cpdf -scale-to-fit "152.4mm 228.6mm" book/liberation-book.pdf -o book/liberation-book.pdf
call start book/liberation-book.pdf
cd %~dp0