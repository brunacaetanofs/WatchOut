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

---

## Loading the triggers (`triggers.sql`)

1. Open the Trigger script - Go to File → Open SQL Script… - Select the file final_project_triggers.sql (this file contains the DELIMITER commands and the logic for all 9 triggers).

2. Execute the script Important: Because triggers use special delimiters ($$), you cannot run them one line at a time.

3. Click the Execute button (yellow lightning icon) to run the entire script at once.

### Trigger Implementation Strategy 

Our group implemented a suite of 9 triggers to automate workflows and enforce business rules across four key areas:

Automation & Workflow: We reduced manual data entry errors by creating triggers that automatically update stock status to 'SOLD' immediately after a purchase. Additionally, we implemented a "Low Stock Warning" system that logs alerts when inventory for a specific model drops below 3 units, ensuring timely reordering.

Business Logic & Gamification: To drive customer retention, we designed a dynamic loyalty system. Customers are automatically upgraded to 'Gold' or 'Platinum' tiers based on their total historical spending. Crucially, we implemented an automated discount engine that applies a 10% or 20% price reduction for these VIP customers at the moment of purchase.

Security & Integrity: We prioritized data security by implementing an audit trail that logs all product price changes. We also enforced data integrity rules that prevent "Double Selling" of the same physical item and block "Fake Reviews" by verifying that a user has actually purchased the product they are reviewing.

Management Control: Finally, we addressed internal management needs. We created a "Salary Guardrail" to prevent unauthorized pay raises exceeding 20%, and a "Dead Stock Tracker" that flags inventory sold after sitting in the warehouse for more than a year, aiding in asset management analysis.
