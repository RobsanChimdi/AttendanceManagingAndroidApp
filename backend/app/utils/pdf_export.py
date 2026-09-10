import io
from datetime import datetime
from typing import List, Dict, Any, Tuple
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle

class PDFExportUtility:
    """
    Utility class for generating formatted PDF reports for attendance data.
    """

    @staticmethod
    def generate_attendance_pdf(
        records: List[Dict[str, Any]],
        title: str = "Daily Attendance Report",
        subtitle: str = ""
    ) -> Tuple[str, bytes]:
        """
        Generate a styled PDF report for attendance records.
        """
        buffer = io.BytesIO()
        doc = SimpleDocTemplate(
            buffer,
            pagesize=A4,
            rightMargin=36,
            leftMargin=36,
            topMargin=36,
            bottomMargin=36
        )

        styles = getSampleStyleSheet()
        
        # Custom Styles
        title_style = ParagraphStyle(
            'ReportTitle',
            parent=styles['Heading1'],
            fontSize=20,
            leading=24,
            textColor=colors.HexColor('#1E293B'),
            alignment=0,
            spaceAfter=4
        )
        
        subtitle_style = ParagraphStyle(
            'ReportSubtitle',
            parent=styles['Normal'],
            fontSize=10,
            leading=14,
            textColor=colors.HexColor('#64748B'),
            spaceAfter=12
        )
        
        header_cell_style = ParagraphStyle(
            'HeaderCell',
            parent=styles['Normal'],
            fontSize=9,
            leading=11,
            textColor=colors.white,
            fontName='Helvetica-Bold'
        )

        cell_style = ParagraphStyle(
            'BodyCell',
            parent=styles['Normal'],
            fontSize=8,
            leading=10,
            textColor=colors.HexColor('#334155')
        )

        elements = []

        # Header Title & Subtitle
        elements.append(Paragraph("<b>EDUTRACK AI</b> - Attendance Management", subtitle_style))
        elements.append(Paragraph(title, title_style))
        if subtitle:
            elements.append(Paragraph(subtitle, subtitle_style))
        
        elements.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#CBD5E1'), spaceAfter=15))

        # Calculate Summaries
        total_students = len(records)
        present_count = sum(1 for r in records if str(r.get('status', '')).lower() == 'present')
        absent_count = sum(1 for r in records if str(r.get('status', '')).lower() == 'absent')
        late_count = sum(1 for r in records if str(r.get('status', '')).lower() == 'late')
        excused_count = sum(1 for r in records if str(r.get('status', '')).lower() == 'excused')
        rate = round((present_count / total_students * 100), 1) if total_students > 0 else 0.0

        # Summary Box Table
        summary_data = [
            [
                Paragraph("<b>Total Records</b>", cell_style),
                Paragraph("<b>Present</b>", cell_style),
                Paragraph("<b>Absent</b>", cell_style),
                Paragraph("<b>Late</b>", cell_style),
                Paragraph("<b>Attendance Rate</b>", cell_style),
            ],
            [
                Paragraph(str(total_students), title_style),
                Paragraph(f"<font color='#166534'>{present_count}</font>", title_style),
                Paragraph(f"<font color='#991B1B'>{absent_count}</font>", title_style),
                Paragraph(f"<font color='#854D0E'>{late_count}</font>", title_style),
                Paragraph(f"<b>{rate}%</b>", title_style),
            ]
        ]

        summary_table = Table(summary_data, colWidths=[100, 100, 100, 100, 120])
        summary_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor('#F8FAFC')),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#E2E8F0')),
            ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#E2E8F0')),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ]))

        elements.append(summary_table)
        elements.append(Spacer(1, 15))

        # Main Data Table
        table_headers = ["Student ID", "Student Name", "Class/Grade", "Status", "Time In", "Verification"]
        table_data = [[Paragraph(h, header_cell_style) for h in table_headers]]

        for r in records:
            status_val = str(r.get('status', 'N/A')).upper()
            status_color = '#166534' if status_val == 'PRESENT' else ('#991B1B' if status_val == 'ABSENT' else '#854D0E')
            
            row = [
                Paragraph(str(r.get('student_id', r.get('roll_number', 'N/A'))), cell_style),
                Paragraph(str(r.get('student_name', r.get('full_name', 'N/A'))), cell_style),
                Paragraph(f"{r.get('grade', '')} {r.get('section', '')}".strip() or 'N/A', cell_style),
                Paragraph(f"<font color='{status_color}'><b>{status_val}</b></font>", cell_style),
                Paragraph(str(r.get('check_in_time', r.get('marked_at', 'N/A')) or 'N/A'), cell_style),
                Paragraph(str(r.get('verification_method', r.get('method', 'MANUAL'))).upper(), cell_style),
            ]
            table_data.append(row)

        if len(table_data) == 1:
            table_data.append([Paragraph("No attendance records found.", cell_style)] + [Paragraph("", cell_style)] * 5)

        data_table = Table(table_data, colWidths=[65, 140, 80, 70, 85, 80])
        data_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1E293B')),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F8FAFC')]),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CBD5E1')),
            ('TOPPADDING', (0, 0), (-1, -1), 5),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ]))

        elements.append(data_table)

        # Footer
        elements.append(Spacer(1, 20))
        generated_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        footer_text = f"Report generated automatically by EduTrack AI on {generated_at}."
        elements.append(Paragraph(footer_text, subtitle_style))

        doc.build(elements)
        pdf_bytes = buffer.getvalue()
        buffer.close()

        filename = f"attendance_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pdf"
        return filename, pdf_bytes

    @staticmethod
    def generate_critical_attendance_pdf(
        records: List[Dict[str, Any]],
        threshold: float = 50.0
    ) -> Tuple[str, bytes]:
        """
        Generate a PDF report specifically for students with critical low attendance rates.
        """
        title = f"Critical Attendance Warning Report (< {threshold}%)"
        subtitle = "Students flagged with attendance rates below the required minimum academic threshold."
        return PDFExportUtility.generate_attendance_pdf(
            records=records,
            title=title,
            subtitle=subtitle
        )
