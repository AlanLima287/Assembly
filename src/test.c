int main(int num) {
   
   int fact = num;
   
   while (num > 2) {
      num--;
      fact *= num;
   }

   return fact;
}