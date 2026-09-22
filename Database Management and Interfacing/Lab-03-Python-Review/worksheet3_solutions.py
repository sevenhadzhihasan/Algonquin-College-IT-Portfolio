#!/usr/bin/env python3

import csv
import json

# ==========================================
# Section A: Functions, math
# ==========================================
def calculate_values(operand1, operand2):
    # Safe fallback check for division by zero
    quotient_val = operand1 / operand2 if operand2 != 0 else "Undefined (cannot divide by zero)"
    
    results = {
        "sum": operand1 + operand2,
        "difference": operand1 - operand2,
        "product": operand1 * operand2,
        "quotient": quotient_val
    }
    return results

user_selection = input("Perform basic arithmetic operations [Y/N]: ").upper()
while user_selection != "N":
    try:
        num1 = float(input("Enter first number: "))
        num2 = float(input("Enter second number: "))
        print(calculate_values(num1, num2))
    except ValueError:
        print("Please enter valid numbers.")
        
    user_selection = input("Another round [Y/N]: ").upper()

# ==========================================
# Section B: Work with lists
# ==========================================
books_list = ["Hamlet", "Moby Dick", "Dune", "Frankenstein"]
books_list.append("The Hobbit")
books_list.remove("Dune")
books_list.sort()
for book in books_list:
    print(book)

# ==========================================
# Section C: Work with dictionaries
# ==========================================
member = {
    "network_id": "smit0001",  # Replace with your actual Algonquin ID if desired
    "first_name": "Jane",
    "last_name": "Smith"
}
member["phone"] = "6131234567"
member["last_name"] = "Doe"
for key, value in member.items():
    print(f"{key} : {value}")

# ==========================================
# Section D: Work with CSV file data
# ==========================================
print("\n--- Reading members.csv ---")
with open('members.csv', 'r') as file:
    csv_dict = csv.DictReader(file)
    for line in csv_dict:
        print(dict(line))

# ==========================================
# Section E: Work with JSON data
# ==========================================
print("\n--- Reading books.json ---")
with open('books.json', 'r') as file:
    book_dict = json.load(file)

# Print each book title
for title in book_dict.keys():
    print(title)

# Dynamic input setup as highly recommended by the solution key guidelines
new_title = input("\nEnter book title to add: ")
new_author = input("Enter author name: ")

# Add the new book data
book_dict[new_title] = new_author

# Save changes with pretty formatting (indent=4)
with open('books.json', 'w') as file:
    json.dump(book_dict, file, indent=4)
print("Changes successfully saved to books.json!")
