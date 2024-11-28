#include <iostream>
#include <vector>
#include <thread>
#include <mutex>
#include <limits>
#include <fstream>
#include <chrono>
#include <cstring>
#include <atomic>

extern "C" {
    void open_disk();
    time_t write_block(size_t size);
    time_t read_block(size_t size);
    void close_disk();
}

// Мьютекс для синхронизации вывода на экран
std::mutex console_mutex;

// Атомарные переменные для подсчёта общего времени
std::atomic<time_t> total_write_time{0};
std::atomic<time_t> total_read_time{0};

// Проверка корректности ввода размера блока
void checkInput(size_t& block_size) {
    std::cout << "Enter size of block (in Kb): ";
    std::cin >> block_size;
    while (std::cin.fail() || block_size <= 0) {
        std::cout << "Invalid input. Try again: ";
        std::cin.clear();
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
        std::cin >> block_size;
    }
    block_size *= 1024; // Конвертируем КБ в байты
}

// Проверка корректности ввода количества итераций
void checkInputI(int& it) {
    std::cout << "Enter count of iterations: ";
    std::cin >> it;
    while (std::cin.fail() || it <= 0) {
        std::cout << "Invalid input. Try again: ";
        std::cin.clear();
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
        std::cin >> it;
    }
}

// Функция для выполнения работы в одном потоке
void disk_ping(int thread_id, size_t block_size, int iterations) {
    time_t thread_write_time = 0;
    time_t thread_read_time = 0;

    for (int i = 0; i < iterations; ++i) {
        // Запись данных
        time_t write_time = write_block(block_size);
        thread_write_time += write_time;

        // Чтение данных
        time_t read_time = read_block(block_size);
        thread_read_time += read_time;

        // Синхронизированный вывод результатов
        {
            std::lock_guard<std::mutex> lock(console_mutex);
            std::cout << "Thread " << thread_id << ", Iteration " << i + 1 
                      << ": Write time = " << write_time << " ns, Read time = " << read_time << " ns\n";
        }
    }

    // Атомарное добавление времени потока к общему времени
    total_write_time += thread_write_time;
    total_read_time += thread_read_time;
}

int main() {
    size_t block_size;
    int iterations;

    // Ввод данных пользователя
    checkInput(block_size);
    checkInputI(iterations);

    // Открытие диска (делается один раз для всех потоков)
    open_disk();

    // Создание и запуск потоков (4 потока фиксировано)
    std::vector<std::thread> threads;
    for (int i = 0; i < 4; ++i) { // Всегда 4 потока
        threads.emplace_back(disk_ping, i + 1, block_size, iterations);
    }

    // Ожидание завершения потоков
    for (auto& thread : threads) {
        thread.join();
    }

    // Закрытие диска
    close_disk();

    // Расчёт среднего времени
    time_t avg_write_time = total_write_time / (iterations * 4); // 4 потока
    time_t avg_read_time = total_read_time / (iterations * 4);

    // Вывод результатов
    std::cout << "\n--- Results ---\n";
    std::cout << "Total Threads: 4\n";
    std::cout << "Average Write Time: " << avg_write_time << " ns\n";
    std::cout << "Average Read Time: " << avg_read_time << " ns\n";

    return 0;
}
