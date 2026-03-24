void main() { 
  int t = -1; 
  print('${t ~/ 3600}:${(t % 3600) ~/ 60}:${t % 60}'); 
}
