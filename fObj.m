function [salida] = fObj(A1, A2, A3, B1, B2, B3, C1, C2, C3, D2, F1, F2, K1, K2, K3)
  % Se define que la letra s denota la variable de la función de transferencia
  s = tf('s');

  % Se definen las funciones de tranferencia del enunciado
  G1 = (A1) / (B1 * s * (s + C1));
  G2 = (A2 * s) / ((B2 * s * (s + (C2 / s))) + D2);
  G3 = (A3 * s * (s + C3)) / (B3);

  H1 = K1 * (1 + (F1 * s));
  H2 = K2 * s * (1 + F2*s);
  H3 = K3 * s;

  % Se define el numerador y denominador de la función de transferencia del
  % sistema, obtenidos a partir de la fórmula de Mason del diagrama de
  % flujo de señal.

  num = (G1 * G2 * G3) + (G1 * H1 * G3);
  den = 1 + (G1 * G2 * G3) + (G2 * H2) + (G2 * G3 * H3) + (G3 * H1 * H3) + (G1 * G3 * H1);

  %Se define la función de transferencia del sistema de manera factorizada,
  %gracias a la función zpk
  FT = zpk(num/den); 

  % Se obtienen los polos de la función de transferencia
  polos = pole(FT);

  temp = 0;
  % Comprobación de la estabilidad del sistema en función de la ubicación
  % de los polos en l,os semiplanos del plano s.
  for i = 1 : length(polos)
      if real(polos(i)) > 1e-4 
          %Es decir, si el polo está en el semiplano derecho
          temp = temp + 10 + 1e4*polos(i);
      end
  end

  % Si no es estable retorna el valor de temp
  if temp > 0
      salida = temp;
  else % Si es estable, se obtiene el tiempo y magnitud del sobreimpulso
      respuesta = stepinfo(FT);
      t = respuesta.PeakTime;
      Imp = respuesta.Overshoot;
      %Se implementa la función objetivo
      salida = abs(t - 1)+ abs((Imp / 20) - 1); 
  end

  % Caso particular donde se presenta un error al obtener el sobreimpulso
  if isnan(salida)
    salida = 1000;
  end