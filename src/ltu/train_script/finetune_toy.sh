#!/bin/bash
#SBATCH -J alm
#SBATCH -o ./log/%j_alm.txt
#SBATCH --qos=regular
#SBATCH --gres=gpu:4
#SBATCH --nodes=1
#SBATCH --partition=a6
#SBATCH --ntasks-per-node=32
#SBATCH --mem=470000
#SBATCH --exclusive

export TRANSFORMERS_CACHE=./hf_cache/
export HF_DATASETS_CACHE=./hf_cache/
output_dir='../exp/ltu_ft_toy/'
mkdir -p $output_dir
cp "$0" ${output_dir}/$(date +"%Y-%m-%d-%H-%M-%S").sh

torchrun --nproc_per_node=4 --master_port=1234 ../finetune.py \
    --base_model '../../../pretrained_mdls/ltu_ori_paper.bin' \
    --data_path '../../../openaqa/data/openaqa_toy_relative.json' \
    --output_dir $output_dir \
    --batch_size 256 \
    --micro_batch_size 4 \
    --num_epochs 1 \
    --learning_rate 1e-4 \
    --cutoff_len 100 \
    --val_set_size 0 \
    --lora_r 8 \
    --lora_alpha 16 \
    --lora_dropout 0.05 \
    --lora_target_modules '[q_proj,v_proj]' \
    --train_on_inputs \
    --group_by_length \
    --wandb_run_name ${output_dir} \
    --save_steps 10 \
    --trainable_params all

# use a smaller micro_batch_size to fit smaller gpus
# you would need to prepare the audio by yourself