import re

py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/analytics/analytics.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace sales report logic
search_sales_report = r"@analytics_bp\.route\('/report/sales'\)\n@login_required\ndef sales_report\(\):.*?mem\.seek\(0\)"
replace_sales_report = '''@analytics_bp.route('/report/sales')
@login_required
def sales_report():
    """Generate Excel or PDF-printable HTML report for Sales."""
    _require_farmer()
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]
    if not farm_ids:
        flash('You have no registered farms.', 'error')
        return redirect(url_for('analytics.index'))

    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')
    selected_farm_id = request.args.get('farm_id')
    selected_type = request.args.get('type')
    format_type = request.args.get('format', 'pdf')
    
    query = SalesRecord.query.filter_by(user_id=current_user.id)
    
    if selected_farm_id:
        try:
            fid = int(selected_farm_id)
            if fid in farm_ids:
                query = query.filter(SalesRecord.farm_id == fid)
        except ValueError:
            pass
            
    start_date = None
    end_date = None
    
    if start_date_str:
        try:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            query = query.filter(SalesRecord.sale_date >= start_date)
        except ValueError:
            pass
            
    if end_date_str:
        try:
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
            query = query.filter(SalesRecord.sale_date <= end_date)
        except ValueError:
            pass
            
    sales = query.order_by(SalesRecord.sale_date.desc(), SalesRecord.created_at.desc()).all()
    
    # Filter by type (Online/On-site)
    if selected_type == 'online':
        sales = [s for s in sales if s.notes and '(Order #' in s.notes]
    elif selected_type == 'onsite':
        sales = [s for s in sales if not s.notes or '(Order #' not in s.notes]
        
    total_qty = sum(s.quantity_sold for s in sales)
    total_rev = sum(s.total_revenue for s in sales)
    
    if format_type == 'excel':
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "Sales Report"
        
        header_fill = PatternFill(start_color="0D631B", end_color="0D631B", fill_type="solid")
        header_font = Font(color="FFFFFF", bold=True)
        
        headers = ["Date", "Type", "Farm", "Buyer", "Egg Type / Notes", "Quantity (Eggs)", "Price per Egg (PHP)", "Total Revenue (PHP)"]
        ws.append(headers)
        
        for col_num, cell in enumerate(ws[1], 1):
            cell.fill = header_fill
            cell.font = header_font
            cell.alignment = Alignment(horizontal="center")
            ws.column_dimensions[openpyxl.utils.get_column_letter(col_num)].width = 20
            
        for s in sales:
            is_online = s.notes and '(Order #' in s.notes
            ws.append([
                s.sale_date.strftime('%Y-%m-%d'),
                "Online" if is_online else "On-site",
                s.farm.name,
                s.buyer_name or 'Walk-in / Unknown',
                s.notes or '',
                s.quantity_sold,
                float(s.price_per_egg),
                float(s.total_revenue)
            ])
            
        ws.append([])
        ws.append(["TOTALS", "", "", "", "", total_qty, "", float(total_rev)])
        totals_row = ws.max_row
        for col_num in range(1, 9):
            ws.cell(row=totals_row, column=col_num).font = Font(bold=True)
            
        mem = io.BytesIO()
        wb.save(mem)
        mem.seek(0)'''

content = re.sub(search_sales_report, replace_sales_report, content, flags=re.DOTALL)

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated sales export route")