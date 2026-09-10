import csv
import io
from typing import List, Dict, Any
from datetime import date, datetime

class CSVExportUtility:
    @staticmethod
    def generate_csv(
        data: List[Dict[str, Any]],
        headers: List[str],
        filename_prefix: str = "report"
    ) -> tuple[str, str]:
        """
        Generate CSV file from data.
        Returns (filename, csv_content)
        """
        output = io.StringIO()
        writer = csv.DictWriter(output, fieldnames=headers, extrasaction='ignore')
        writer.writeheader()
        
        for row in data:
            # Convert datetime/date objects to strings
            processed_row = {}
            for key, value in row.items():
                if isinstance(value, (datetime, date)):
                    processed_row[key] = value.isoformat()
                elif value is None:
                    processed_row[key] = ""
                else:
                    processed_row[key] = str(value)
            writer.writerow(processed_row)
        
        csv_content = output.getvalue()
        output.close()
        
        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{filename_prefix}_{timestamp}.csv"
        
        return filename, csv_content

    @staticmethod
    def generate_attendance_csv(records: List[Dict[str, Any]]) -> tuple[str, str]:
        """Generate CSV specifically for attendance records."""
        headers = [
            'id',
            'date',
            'student_id',
            'student_name',
            'student_id_str',
            'grade',
            'section',
            'class_name',
            'status',
            'method',
            'recognized_at'
        ]
        return CSVExportUtility.generate_csv(records, headers, "attendance_report")

    @staticmethod
    def generate_critical_attendance_csv(records: List[Dict[str, Any]]) -> tuple[str, str]:
        """Generate CSV specifically for critical attendance records."""
        headers = [
            'student_id',
            'student_name',
            'student_id_str',
            'grade',
            'section',
            'attendance_percentage',
            'required_percentage',
            'guardian_name',
            'guardian_phone',
            'is_critical'
        ]
        return CSVExportUtility.generate_csv(records, headers, "critical_attendance_report")
