#!/usr/bin/env python3
"""
Program: library_hadz0024.py
Description: Final completed library control application managing operational workflows 
             with PostgreSQL connectivity using psycopg2 and sequential fetchone tracking loops.
             Fully compliant with Milestone #3 specifications.
"""

###########
# Imports #
###########
import sys
import psycopg2

#############
# Constants #
#############
NETWORK_ID = "hadz0024"
DATABASE_NAME = f"library_{NETWORK_ID}"
DATABASE_USER = f"library_{NETWORK_ID}"


########################
# Function definitions #
########################

def show_menu():
    """
    Function purpose: Display menu options to stdout.
    Note: Use digits ('1', '2', '3') for menu options and 'q' to quit.
    """
    print("\n\t1. Display all books, sorted by title.")
    print("\t2. Display all members, sorted by name.")
    print("\t3. List all current book loans by a member.")
    print("\t4. Insert a book loan.")
    print("\t5. Update a book loan return date.")
    print("\tQ Quit")


def get_menu_option(prompt="Select an option (1-5 or Q): "):
    """
    Function purpose: Get menu option from user and validate input against limits.
    Function parameters: prompt
    Function return: user-selected menu option string
    """
    valid_entries = ['1', '2', '3', '4', '5', 'q']
    choice = input(prompt).strip().lower()
    while choice not in valid_entries:
        print("Invalid choice. Please select 1, 2, 3, 4, 5, or Q.")
        choice = input(prompt).strip().lower()
    return choice


def get_attribute_value(prompt):
    """
    Function purpose: Prompt the user for an attribute value used in a query.
    Function parameters: prompt
    Function return: attribute value string
    """
    value = input(prompt).strip()
    while not value:
        print("Input field cannot be left blank.")
        value = input(prompt).strip()
    return value


def query_member_id(phone):
    """
    Function purpose: Return member ID based on member phone number.
    Function parameters: member phone number
    Function return: member ID integer value or None
    """
    sql_query = "SELECT member_id FROM member WHERE phone = %s;"
    cursor.execute(sql_query, (phone,))
    record = cursor.fetchone()
    if record:
        return record[0]  # Extracts scalar integer from row tuple
    return None


def display_query():
    """
    Function purpose: Display the result set of the query sequentially using fetchone loop.
    Function parameters: none
    Function return: none
    """
    record = cursor.fetchone()
    if not record:
        print("\t[-] No matching records found matching parameter indexes.")
        return

    print("\n\t" + "-" * 75)
    while record:
        print("\t", *[str(col) if col is not None else "Active (Out)" for col in record])
        record = cursor.fetchone()
    print("\t" + "-" * 75)


def query_members():
    """
    Function purpose: Return all members in the database, sorted strictly by last name then first name.
    Function parameters: none
    Function return: none
    """
    sql_query = "SELECT first_name, last_name, phone FROM member ORDER BY last_name, first_name;"
    cursor.execute(sql_query)


def query_books():
    """
    Function purpose: Return all books, including book copies, in the database.
    Function parameters: none
    Function return: none
    """
    sql_query = """
        SELECT b.title, b.isbn, c.copy_id, c.acquisition_date 
        FROM book b
        LEFT JOIN book_copy c ON b.isbn = c.isbn
        ORDER BY b.title;
    """
    cursor.execute(sql_query)


def query_loans_by_member(member_id):
    """
    Function purpose: Return all current active loans of a member.
    Function parameters: member ID
    Function return: none
    """
    sql_query = """
        SELECT l.loan_id, c.copy_id, b.title, l.loan_date, (l.loan_date + b.rental_days) AS due_date 
        FROM loan l 
        JOIN book_copy c ON l.copy_id = c.copy_id 
        JOIN book b ON c.isbn = b.isbn 
        WHERE l.member_id = %s AND l.return_date IS NULL
        ORDER BY l.loan_date;
    """
    cursor.execute(sql_query, (member_id,))


def insert_loan(copy_id, member_id):
    """
    Function purpose: Insert a loan for a member with required availability validations.
    Function parameters: book copy ID, member ID
    Function return: none
    """
    # Enforce data check 1: Does copy exist in system inventory tables?
    cursor.execute("SELECT copy_id FROM book_copy WHERE copy_id = %s;", (copy_id,))
    if not cursor.fetchone():
        print(f"\t[Error] Book copy ID {copy_id} does not exist in collection tables.")
        return

    # Enforce data check 2: Is copy available or already on loan?
    cursor.execute("SELECT loan_id FROM loan WHERE copy_id = %s AND return_date IS NULL;", (copy_id,))
    if cursor.fetchone():
        print(f"\t[Error] Book copy ID {copy_id} is currently checked out on active loan.")
        return

    sql_query = "INSERT INTO loan (copy_id, member_id, loan_date, return_date) VALUES (%s, %s, CURRENT_DATE, NULL);"
    cursor.execute(sql_query, (copy_id, member_id))
    connection.commit()
    print(f"\t[Success] Loan transaction successfully committed for Copy ID: {copy_id}.")


def update_loan_return(loan_id):
    """
    Function purpose: Updates an existing loan in the database to log a return date.
    Function parameters: loan ID
    Function return: none
    """
    sql_check = "SELECT return_date FROM loan WHERE loan_id = %s;"
    cursor.execute(sql_check, (loan_id,))
    result = cursor.fetchone()
    
    if not result:
        print(f"\t[Error] Loan database tracking index {loan_id} not found.")
        return
        
    # Check the actual unpacked element inside the result tuple
    if result[0] is not None:
        print(f"\t[Notice] This loan row was already closed out on date: {result[0]}.")
        return

    sql_query = "UPDATE loan SET return_date = CURRENT_DATE WHERE loan_id = %s;"
    cursor.execute(sql_query, (loan_id,))
    connection.commit()
    print(f"\t[Success] Loan signature record {loan_id} marked as returned.")


################
# Main program #
################

# Establish a connection to the database
try:
    connection = psycopg2.connect(database=DATABASE_NAME, user=DATABASE_USER)
except psycopg2.DatabaseError:
    print("Error: Connection to database NOT established.")
    sys.exit(1) # early exit if DB not available

print("Database connection successful")

# Set up the cursor
cursor = connection.cursor() # global variable

# Priming step to manage proper flagless read-loop layout logic streams
menu_option = ""

while menu_option != 'q':
    show_menu()
    menu_option = get_menu_option()
    
    if menu_option == '1':
        print("\n--- Displaying Books Architecture Matrix (Sorted by Title) ---")
        query_books()
        display_query()
        
    elif menu_option == '2':
        print("\n--- Displaying Registered Library Users Matrix ---")
        query_members()
        display_query()
        
    elif menu_option == '3':
        phone = get_attribute_value("Enter member phone number: ")
        m_id = query_member_id(phone)
        if m_id is not None:
            print(f"\n--- Current Outstanding Loans for Member ID {m_id} ---")
            query_loans_by_member(m_id)
            display_query()
        else:
            print("\t[Error] No member matching that phone number was found.")
            
    elif menu_option == '4':
        phone = get_attribute_value("Enter member phone number: ")
        m_id = query_member_id(phone)
        if m_id is not None:
            copy_ref = get_attribute_value("Enter book copy id: ")
            if copy_ref.isdigit():
                insert_loan(int(copy_ref), m_id)
            else:
                print("\t[Error] Primary and foreign identifiers must be integer keys.")
        else:
            print("\t[Error] Member not in database.")
            
    elif menu_option == '5':
        print("Update a book loan return for a member.")
        query_members()
        display_query()
        member_phone = get_attribute_value("Enter member phone number: ")
        member_id = query_member_id(member_phone)
        if member_id:
            query_loans_by_member(member_id)
            display_query()
            loan_id = get_attribute_value("Enter loan id: ")
            if loan_id.isdigit():
                update_loan_return(int(loan_id))
            else:
                print("\t[Error] Loan ID must be a numeric integer.")
        else:
            print("Member not in database.")
            
    elif menu_option == 'q':
        print("\nClosing driver routines. Freeing socket parameters...")

# Close the cursor and the database connection at the very end of your program
cursor.close()
connection.close()
print("Database connection and cursor references safely freed. Goodbye!")

