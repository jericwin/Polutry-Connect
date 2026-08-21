import re

py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/analytics/analytics.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add the new route at the end of the file
new_route = '''
@analytics_bp.route('/report/expenses')
@login_required
def expenses_report():
    """Generate Excel or PDF-printable HTML report for Expenses."""
    from app.models import Expense
    _require_farmer()
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]
    if not farm_ids:
        flash('You have no registered farms.', 'error')
        return redirect(url_for('analytics.index'))

    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')
    selected_farm_id = request.args.get('farm_id')
    format_type = request.args.get('format', 'pdf')
    
    query = Expense.query.filter(Expense.farm_id.in_(farm_ids))
    
    if selected_farm_id:
        try:
            fid = int(selected_farm_id)
            if fid in farm_ids:
                query = query.filter(Expense.farm_id == fid)
        except ValueError:
            pass
            
    start_date = None
    end_date = None
    
    if start_date_str:
        try:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            query = query.filter(Expense.expense_date >= start_date)
        except ValueError:
            pass
            
    if end_date_str:
        try:
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
            query = query.filter(Expense.expense_date <= end_date)
        except ValueError:
            pass
            
    expenses = query.order_by(Expense.expense_date.desc(), Expense.created_at.desc()).all()
    
    total_amount = sum(e.amount for e in expenses)
    
    if format_type == 'excel':
        import openpyxl
        from openpyxl.styles import Font, PatternFill, Alignment
        import io
        
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "Expenses Report"
        
        header_fill = PatternFill(start_color="B91C1C", end_color="B91C1C", fill_type="solid")
        header_font = Font(color="FFFFFF", bold=True)
        
        headers = ["Date", "Farm", "Category", "Description", "Frequency", "Amount (PHP)"]
        ws.append(headers)
        
        for col_num, cell in enumerate(ws[1], 1):
            cell.fill = header_fill
            cell.font = header_font
            cell.alignment = Alignment(horizontal="center")
            ws.column_dimensions[openpyxl.utils.get_column_letter(col_num)].width = 20
            
        for e in expenses:
            ws.append([
                e.expense_date.strftime('%Y-%m-%d'),
                e.farm.name,
                e.category.value if e.category else '',
                e.description or '',
                e.frequency.value if e.frequency else '',
                float(e.amount)
            ])
            
        ws.append([])
        ws.append(["TOTAL", "", "", "", "", float(total_amount)])
        totals_row = ws.max_row
        for col_num in range(1, 7):
            ws.cell(row=totals_row, column=col_num).font = Font(bold=True)
            
        mem = io.BytesIO()
        wb.save(mem)
        mem.seek(0)
        
        return send_file(
            mem,
            as_attachment=True,
            download_name=f"Expenses_Report_{datetime.utcnow().strftime('%Y%m%d')}.xlsx",
            mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )

    # Otherwise render PDF
    html_out = render_template(
        'analytics/expenses_report_pdf.html',
        expenses=expenses,
        total_amount=total_amount,
        start_date=start_date,
        end_date=end_date,
        report_date=datetime.utcnow()
    )

    pdf_file = _generate_pdf(html_out)
    return send_file(
        pdf_file,
        as_attachment=False,
        download_name=f"Expenses_Report_{datetime.utcnow().strftime('%Y%m%d')}.pdf",
        mimetype='application/pdf'
    )
'''

content += new_route

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Added /report/expenses route")