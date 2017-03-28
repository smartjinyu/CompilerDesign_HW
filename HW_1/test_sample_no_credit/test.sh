#!/bin/sh
echo "Test pragma_source_off.c"
./scanner < pragma_source_off.c > my_test_answer/my_pragma_source_off.out
diff my_test_answer/my_pragma_source_off.out test_answer_student/pragma_source_off.out

echo "Test pragma_source_off_1.c"
./scanner < pragma_source_off_1.c > my_test_answer/my_pragma_source_off_1.out
diff my_test_answer/my_pragma_source_off_1.out test_answer_student/pragma_source_off_1.out

echo "Test pragma_token_off.c"
./scanner < pragma_token_off.c > my_test_answer/my_pragma_token_off.out
diff my_test_answer/my_pragma_token_off.out test_answer_student/pragma_token_off.out

echo "Test test0_1.c"
./scanner < test0_1.c > my_test_answer/my_test0_1.out
diff my_test_answer/my_test0_1.out test_answer_student/test0_1.out

echo "Test test0_1_error.c"
./scanner < test0_1_error.c > my_test_answer/my_test0_1_error.out
diff my_test_answer/my_test0_1_error.out test_answer_student/test0_1_error.out

echo "Test test0_2.c"
./scanner < test0_2.c > my_test_answer/my_test0_2.out
diff my_test_answer/my_test0_2.out test_answer_student/test0_2.out