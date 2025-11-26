#!/bin/bash


aritmetik_ifade() { #Ornek (2+6*7)/8
    while true; do
        read -p "İfade girin (çıkış: q): " a
        if [[ "$a" == "q" || "$a" == "Q" ]]; then
            break
        fi
        echo "scale=5; $a" | bc -l  
    done
}

us_al() { #Ornek 2 3 -> Sonuc 8
    while true; do
        read -p "taban & üs (çıkış: q): " a b
        if [[ "$a" == "q" || "$a" == "Q" ]]; then
            break
        fi
        echo "scale=5; $a^$b" | bc -l  
    done
}

karakok() {
    while true; do
        read -p "Sayi (çıkış: q): " a 
        if [[ "$a" == "q" || "$a" == "Q" ]]; then
            break
        fi
        echo "scale=5; sqrt($a)" | bc -l    
    done
}

trigonometri() {
    while true; do
        read -p "sin/cos x (örn: sin 0.5) (çıkış: q): " a b
        if [[ "$a" == "q" || "$a" == "Q" ]]; then
            break
        elif [[ "$a" == "sin" || "$a" == "SIN" ]]; then
            echo "scale=5; s($b)" | bc -l
        elif [[ "$a" == "cos" || "$a" == "COS" ]]; then
            echo "scale=5; c($b)" | bc -l
        else
            echo "Geçersiz (sadece sin/cos desteklenir)"
        fi  
    done
}

polinomYapisi(){
    numParam=$#
    params=("$@")
    ifade=""
    x=0
    for (( i=$(($#-1)); i>-1; i-- )) do
        if (( i == 0 )); then
            ifade+="${params[$x]}"
        elif ((i == 1)); then
            ifade+="${params[$x]}x + "
        else
            ifade+="${params[$x]}x^$i + "
        fi
        ((x+=1))
    done
    echo "P(x) = $ifade"
}

degerHesapla(){
    numParam=$#
    params=("$@")
    sonuc=0
    j=$((numParam-1))

    read -p "x degeri (çıkış: q): " x
    if [[ "$x" == "q" || "$x" == "Q" ]]; then
            return 1
    fi
    
    # Polinom hesaplama
    # **Not:** Burada Bash'in kendi aritmetik işlemi kullanılır.
    # Büyük sayılar veya ondalıklı sayılar için bc ile yeniden yazmak daha güvenilir olabilir.
    for (( i=0; i < $numParam; i++ )); do
        (( sonuc += params[j] * x**i ))
        ((j-=1))
    done
    
    echo "--------------"
    echo "| f($x) = $sonuc |"
    echo "--------------"
}

paraDegerHesapla(){
    x=${1}              # İlk parametre = x değeri
    shift               # x'i array'den çıkar
    params=("$@")       # Geriye kalan parametreler = katsayılar

    numParam=${#params[@]}
    # Horner metodu (veya bir döngü) ile bc kullanarak hesaplama
    ifade=""
    for (( i=0; i<numParam; i++ )); do
        j=$((numParam - 1 - i)) # Katsayı indeksi (params[j] katsayı, i üs)
        # Bash aritmetiği yerine bc kullanılıyor
        if [ "$ifade" = "" ]; then
             ifade="${params[j]}*($x^$i)"
        else
             ifade+="+${params[j]}*($x^$i)"
        fi
    done

    # bc ile hesapla ve sonucu döndür
    echo "scale=5; $ifade" | bc -l
}

ciz(){
    numParam=$#
    params=("$@")
    read -p "Aralık girin (başlangıç bitiş): " aD uD
    clear
    polinomYapisi "${params[@]}"  # Polinomu ekrana yazdırma
    scale=0.2
    
    # Eksen etiketleri
    printf "\n"
    printf "%5s | %s\n" "x" "y ekseni (*)"
    printf "______|____________________________________________________________________\n"
    
    for ((i=$aD; i <= $uD; i++)); do
        y_float=$(paraDegerHesapla "$i" "${params[@]}") # bc'den float değer al
        
        # Ölçekleme ve tam sayıya çevirme
        y_scaled=$(echo "$y_float * $scale" | bc -l)
        # printf kullanarak yuvarlama yapmak yerine sadece tam kısmı alalım
        y_int=${y_scaled%.*}
        
        # Negatif değerler için y-ekseninin soluna * koyalım
        if (( y_int < 0 )); then
            abs_y_int=$(( -y_int ))
            
            # x değeri ve boşluklar
            printf "%4d|" "$i"
            
            # Sol taraf boşluk
            for ((j=0; j < abs_y_int; j++)); do
                printf " "
            done
            # Sol tarafa * ve sağ tarafa sıfır boşluk
            printf "*\n"
            
        else
            # Pozitif değerler için
            printf "%4d|" "$i"
            j=0
            while (( j<y_int )); do
                printf " "
                ((j+=1))
            done
            printf "*\n"
        fi
    done
    printf "______|____________________________________________________________________\n"
}

polinom_hesap(){
    echo "Polinom katsayılarını girin (sabit katsayı en sonda olmalı, örn: 1 2 3 4):"
    read -a params
    polinomYapisi "${params[@]}"
    while true; do
        degerHesapla "${params[@]}"
        if [[ $? -eq 1 ]]; then
            break
        fi
    done
}
grafik_ciz(){
    echo "Polinom katsayılarını girin (sabit katsayı en sonda olmalı, örn: 1 2 3 4):"
    read -a params
    polinomYapisi "${params[@]}"
    ciz "${params[@]}"
}

# --- YENİ EKLENEN FONKSİYONLAR ---

logaritma() {
    while true; do
        read -p "İşlem (ln/exp) ve Sayı (örn: ln 10) (çıkış: q): " islem sayi
        
        if [[ "$islem" == "q" || "$islem" == "Q" ]]; then
            break
        fi

        case "$islem" in
            ln)
                echo "ln($sayi) = $(echo "scale=5; l($sayi)" | bc -l)"
                ;;
            exp)
                echo "e^$sayi = $(echo "scale=5; e($sayi)" | bc -l)"
                ;;
            *)
                echo "Geçersiz işlem. Lütfen 'ln' veya 'exp' girin."
                ;;
        esac
    done
}

faktoriyel() {
    while true; do
        read -p "Faktöriyelini hesaplamak istediğiniz tam sayıyı girin (çıkış: q): " n
        
        if [[ "$n" == "q" || "$n" == "Q" ]]; then
            break
        fi
        
        if ! [[ "$n" =~ ^[0-9]+$ ]]; then
            echo "Geçersiz giriş. Lütfen pozitif bir tam sayı girin."
            continue
        fi

        if (( n < 0 )); then
            echo "Negatif sayıların faktöriyeli tanımsızdır."
            continue
        fi

        if (( n == 0 )); then
            echo "0! = 1"
            continue
        fi

        sonuc=1
        for (( i=1; i<=n; i++ )); do
            (( sonuc *= i ))
        done
        echo "$n! = $sonuc"
    done
}

derece_radyan_donusum() {
    PI=$(echo "scale=10; 4*a(1)" | bc -l)

    while true; do
        echo "  d2r: Derece -> Radyan"
        echo "  r2d: Radyan -> Derece"
        read -p "Dönüşüm (d2r/r2d) ve Değer (örn: d2r 90) (çıkış: q): " yon deger
        
        if [[ "$yon" == "q" || "$yon" == "Q" ]]; then
            break
        fi

        case "$yon" in
            d2r)
                # derece * (PI / 180)
                radyan=$(echo "scale=5; $deger * ($PI / 180)" | bc -l)
                echo "$deger derece = $radyan radyan"
                ;;
            r2d)
                # radyan * (180 / PI)
                derece=$(echo "scale=5; $deger * (180 / $PI)" | bc -l)
                echo "$deger radyan = $derece derece"
                ;;
            *)
                echo "Geçersiz yön. Lütfen 'd2r' veya 'r2d' girin."
                ;;
        esac
    done
}


# --- ANA DÖNGÜ VE MENÜ ---

while true; do
    echo -e "\n------ Hesap Makinesi ------"
    echo "Lütfen bir seçenek numarası girin ve 'q' ile alt menülerden çıkın."
    echo "--------------------------------------------------------------------------------------"
    
    
    echo "1) Aritmetik İfade (Örn: (2+6)*7/8)"
    echo "2) Üs Alma (Örn: 2 3 -> 8)"
    echo "3) Karakök (Örn: 16)"
    echo "4) Trigonometri (Örn: sin 0.5 veya cos 1)"
    echo "5) Polinom Hesaplama (Örn: Katsayılar: 1 0 -4, sonra x=3 girilir)"
    echo "6) Polinom Grafik Çizme (Örn: Katsayılar: 1 -2 0, Aralık: -3 5)"
    echo "7) Logaritma/Üstel (Örn: ln 10 veya exp 2)"
    echo "8) Faktöriyel (Örn: 5 -> 120)"
    echo "9) Derece/Radyan Dönüşümü (Örn: d2r 90 veya r2d 1.57)"
    echo "0) Çıkış"
    echo "--------------------------------------------------------------------------------------"
    echo -n "Seçim yap: "
    read secim

    case $secim in
    1)
        aritmetik_ifade
        ;;
    2)
        us_al
        ;;
    3)
        karakok
        ;;
    4)
        trigonometri
        ;;
    5)
        polinom_hesap
        ;;
    6)
        grafik_ciz
        ;;
    7)
        logaritma
        ;;
    8)
        faktoriyel
        ;;
    9)
        derece_radyan_donusum
        ;;
    0)
        echo "Hesap makinesi kapatılıyor. Görüşmek üzere!"
        break
        ;;
    *)
        echo "Geçersiz seçim. Lütfen menüdeki numaralardan birini girin."
        ;;
    esac

done
