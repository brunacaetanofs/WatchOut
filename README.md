# WatchOut

## How to run the WatchOut database in MySQL Workbench

1. **Open MySQL Workbench**  
   Launch MySQL Workbench and connect to your MySQL server (e.g., `Local instance MySQL`).

2. **Open a new SQL editor tab**  
   Go to **File → Open SQL Script…** and select the file `watchout_schema.sql` (this file contains all `CREATE DATABASE`, `CREATE TABLE` and `INSERT` statements for the schema, or at least all the `CREATE DATABASE` / `CREATE TABLE` statements).  
   Alternatively, you can open a blank tab with **File → New Query Tab** and paste the contents of the script.

3. **Execute the schema script**  
   Make sure you are connected to the server, then click the **Execute** button (yellow lightning icon) to run the entire script.  
   The script will:
   - Drop and recreate the `watchout` database (if it already exists)  
   - Create all tables (`Customer`, `Brand`, `Product`, `StockUnit`, `Employee`, `SalaryHistory`, `OrderHeader`, `OrderItem`, `Review`, `LogPrice`, etc.)

4. **Verify the schema and tables**  
   In the **SCHEMAS** panel on the left:
   - Right-click and choose **Refresh All**  
   - Expand the `watchout` schema  
   - Check that all tables were created successfully

5. **Run custom queries**  
   Open a new query tab, select the `watchout` schema as default (right-click → **Set as Default Schema**), and write your own `SELECT`, `JOIN`, `GROUP BY`, etc., to explore the structure.

---

## Loading the sample data (`insert_data.sql`)

If the data is separated into a second script (e.g. `insert_data.sql`), follow these steps after the schema is created:

1. **Ensure the `watchout` schema exists**  
   Run `watchout_schema.sql` first (as described above) so that all tables and foreign keys are created.

2. **Open the data script**  
   - Go to **File → Open SQL Script…**  
   - Select `insert_data.sql` (this file contains all `INSERT` statements for brands, products, customers, employees, stock units, orders, order items, reviews, etc.).

3. **Check the active database**  
   At the top of the `insert_data.sql` file there should be a line like:
   ```sql
   USE watchout;
