// 1. Restaurant Delivery Date Calculator
DateTime calculateDeliveryDate(
    DateTime orderDate, int workingDays, int autoIncrementDays) {
  int daysAdded = 0;
  DateTime deliveryDate = orderDate;

  while (daysAdded < autoIncrementDays) {
    deliveryDate = deliveryDate.add(const Duration(days: 1));
    if (deliveryDate.weekday <= workingDays) {
      daysAdded++;
    }
  }

  return deliveryDate;
}

// 2. Cycle Detection in Order Processing Queue
class ListNode {
  int value;
  ListNode? next;
  ListNode(this.value);
}

bool hasCycle(ListNode? head) {
  if (head == null) return false;
  ListNode? slow = head;
  ListNode? fast = head;

  while (fast != null && fast.next != null) {
    slow = slow!.next;
    fast = fast.next!.next;
    if (slow == fast) return true;
  }

  return false;
}

// 3. Custom Fibonacci Calculator for Revenue Projections
int customFibonacci(int n, int first, int second) {
  if (n == 1) return first;
  if (n == 2) return second;

  int prev1 = first, prev2 = second, current = 0;
  for (int i = 3; i <= n; i++) {
    current = prev1 + prev2;
    prev1 = prev2;
    prev2 = current;
  }
  return current;
}

// Unit Tests
void main() {
  // Test Case 1: Delivery Date Calculator
  final workingDays = 5;
  final orderDate = DateTime(2024, 2, 8);
  final autoIncrementDays = 2;
  print('Delivery Date Test: ${calculateDeliveryDate(orderDate, workingDays, autoIncrementDays)}');

  // Test Case 2: Cycle Detection
  final node1 = ListNode(1);
  final node2 = ListNode(2);
  node1.next = node2;
  node2.next = node1;
  print('Cycle Detection Test: ${hasCycle(node1)}');


  // Test Case 3: Custom Fibonacci
  print('Custom Fibonacci Test: ${customFibonacci(6, 3, 5)}');
}
