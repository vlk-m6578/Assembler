### Вариант 13:   Тестирование скорости диска "пингом". Создайте инструмент, который будет "пинговать" ваш диск, записывая и затем считывая небольшие блоки данных для измерения задержек. Идея состоит в том, чтобы определить задержку (латентность) записи и чтения диска. Запросите у пользователя размер блока данных для теста (например, 1 КБ, 10 КБ, 100 КБ). Запросите количество итераций (например, 100 пингов). Запись на диск: Зафиксируйте текущее время с помощью прерывания таймера. Запишите блок данных указанного размера на диск. Зафиксируйте время после записи. Рассчитайте разницу между временами для определения времени записи. Чтение с диска: Зафиксируйте текущее время. Прочтите блок данных с диска. Зафиксируйте время после чтения. Рассчитайте разницу между временами для определения времени чтения. Рассчитайте среднее время записи и чтения за все итерации. Используйте прерывания для обработки ошибок (например, недостаточно места на диске). Многопоточное тестирование: При запуске теста, создайте несколько потоков (например, 4), каждый из которых будет "пинговать" диск. Это позволит симулировать реальную среду, где диск может обрабатывать несколько операций одновременно(реализация на C++).
----------------------
##### ПРИМЕЧАНИЯ: rdtsc не возвращает текущее время, а возращает количество тактов процессора; для нахождения времени должна использоваться частота процессора.
##### Запуск в VS Code на Linux Ubuntu:
#### nasm -f elf64 disk_ping.asm -o disk_ping.o ----> g++ -fPIE -pie main.cpp disk_ping.o -o main ----> ./main
##### Запуск в VS Code через gdb отладчик:
#### nasm -g -F dwarf -f elf64 disk_ping.asm -o disk_ping.o ----> g++ -g -fPIE -pie main.cpp disk_ping.o -o main ----> gbd ./main
##### Таблица системных вызовов Linux
#### https://syscalls.mebeim.net/?table=x86/64/x64/v6.5
##### Расширения для NASM в VS Code:
![image](https://github.com/user-attachments/assets/8a7016e5-f82b-493d-a7ba-8ab725378104)
![image](https://github.com/user-attachments/assets/7a8c4b33-9f82-47b0-9905-71feacb4714c)




