/*
  Opta Blink (generic)
  Some OPTA variants don't expose a default LED_BUILTIN. Adjust pin if needed.
*/
#ifndef LED_BUILTIN
#define LED_BUILTIN 13
#endif

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
  delay(500);
}