import csv
import re
import os

def convert_time_to_seconds(time_str):
    h, m, s = time_str.split(':')
    return int(h) * 3600 + int(m) * 60 + float(s)

def extract_log_info_and_generate_csv(log_file_path, output_csv_path, target_directory):
    data = []

    unwanted_chars = re.compile(r'(\x1B\[[0-9;]*m)|([^\x00-\x7F])')

    with open(log_file_path, 'r') as file:
        lines = file.readlines()

        previous_task = None

        for i in range(len(lines)):
            if "TASK [" in lines[i]:
                task_name = lines[i].strip().split('TASK [')[1].split(']')[0]

                full_task_path = lines[i + 1].strip().split('task path: ')[1]
                if target_directory in full_task_path:
                    start_index = full_task_path.find(target_directory) + len(target_directory)
                    partial_task_path = full_task_path[start_index:]
                else:
                    partial_task_path = full_task_path

                partial_task_path = unwanted_chars.sub('', partial_task_path).strip()

                time_to_complete = lines[i + 2].strip().split('(')[1].split(')')[0]

                if previous_task:
                    previous_task[2] = time_to_complete  # Shift the time to the previous task
                    data.append(previous_task)

                previous_task = [task_name, partial_task_path, None]  # Placeholder for the next time_to_complete

        # Ensure the last task is also included
        if previous_task:
            previous_task[2] = time_to_complete if time_to_complete else 'N/A'
            data.append(previous_task)

    # Convert time strings to seconds for sorting
    for row in data:
        if row[2] != 'N/A':
            row[2] = convert_time_to_seconds(row[2])

    # Sort the data by time (now in seconds)
    data.sort(key=lambda x: x[2], reverse=True)

    # Convert times back to original string format
    for row in data:
        if isinstance(row[2], float):
            row[2] = f'{int(row[2] // 3600):02}:{int((row[2] % 3600) // 60):02}:{row[2] % 60:.3f}'

    # Write the sorted data to a CSV file
    with open(output_csv_path, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(['Task Name', 'Task Path', 'Time to Complete'])
        csvwriter.writerows(data)

    print(f"Data extracted, sorted, and saved to {output_csv_path}")

# File paths
log_file_path = './RL9-ofed-fatimage-177.txt'
output_csv_path = 'RL9-ofed-fatimage-177.csv'
target_directory = '/ansible/'

# Run the function
extract_log_info_and_generate_csv(log_file_path, output_csv_path, target_directory)
