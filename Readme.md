# A Simple RV32I Pipeline CPU

- This project is a RISC-V CPU implementation by Rax for learning pipeline CPU architecture.
- The current goal is to run a small RV32I program in an end-to-end simulation on this CPU.
- Waiting to be done

## 1 安裝工具 (Ubuntu / Debian)
```bash
sudo apt update
sudo apt install -y iverilog gtkwave

iverilog -V
gtkwave --version
```

## 2 建立常用資料夾
```bash
cd /home/yes43014301/CPU
mkdir -p build program wave
```

## 3 編譯與執行模擬
有 `CPU_tb.v` (testbench) 與 `CPU.v`/其他模組後：

```bash
cd /home/yes43014301/CPU

iverilog -g2012 -o build/cpu_sim \
  CPU_tb.v CPU.v \
  Program_Counter.v Instruction_Fetch.v Instruction_Decode.v Execution.v Memory.v Write_Back.v \
  ALU.v ALU_Control.v Control_Unit.v Register_File.v Immediate_Generator.v \
  Instruction_Memory.v Data_Memory.v Branch_Comparator.v

vvp build/cpu_sim
```

如果你想自動抓目前資料夾所有 `.v`：
```bash
cd /home/yes43014301/CPU
find . -maxdepth 1 -name "*.v" | sort | xargs iverilog -g2012 -o build/cpu_sim
vvp build/cpu_sim
```

## 4 使用二進位 `.txt` 當程式輸入
先準備指令檔，每行一個 32-bit binary instruction
以下舉例:
```bash
cd /home/yes43014301/CPU
cat > program/prog.txt <<'EOT'
00000000000100000000000010010011
00000000001000000000000100010011
00000000001000001000000110110011
EOT
```

之後重新編譯並執行：
```bash
cd /home/yes43014301/CPU
iverilog -g2012 -o build/cpu_sim *.v
vvp build/cpu_sim
```

註：你的 Verilog 記憶體模組通常會用 `$readmemb("program/prog.txt", mem);` 來讀這個檔案。

## 5 Waveform 除錯 (GTKWave)
執行模擬後，若 testbench 產生了 VCD（例如 `wave/cpu.vcd`）：

```bash
cd /home/yes43014301/CPU
gtkwave wave/cpu.vcd
```

常見一鍵流程：
```bash
cd /home/yes43014301/CPU
iverilog -g2012 -o build/cpu_sim *.v && vvp build/cpu_sim && gtkwave wave/cpu.vcd
```

## 6 常見問題
- `No top level modules`：代表目前還沒有完成 top/testbench module 宣告。
- `Unable to open input file`：通常是 `program/prog.txt` 路徑錯誤。
- 沒有波形檔：確認 testbench 有 dump VCD（例如 `$dumpfile/$dumpvars`）。

## 7 Waiting to be done :
- Branch_Comparator.v
- Branch_predictor.v
- CPU_tb.v
- CPU.v
- Data_Memory.v
- Execution.v
- Forwarding_Unit.v
- Hazard_detection.v
- Memory.v
- Write_Back.v


## 8 finish file
- Adder.v
- ALU.v
- Control_Unit.v
- Mux2.v
- Mux3.v
- Immediate_Generator.v
- Instruction_Decode.v
- Instruction_Fetch.v
- Instruction_Memory.v
- Instruction_Parser.v
- Program_Counter.v
- Register_File.v

## References
- David A. Patterson and John L. Hennessy, *Computer Organization and Design: The Hardware/Software Interface (RISC-V Edition)*, Morgan Kaufmann.
