import streamlit as st
import pandas as pd

# 1. CONFIGURAÇÃO DA PÁGINA
st.set_page_config(
    page_title="Starcar | Painel de Negócios",
    page_icon="🚗",
    layout="centered"
)

# Estilização básica para manter o app limpo
st.markdown("""
    <style>
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
    header {visibility: hidden;}
    .stButton>button { width: 100%; border-radius: 8px; }
    .box-carro { background-color: #f9f9f9; padding: 15px; border-radius: 10px; border: 1px solid #eee; margin-bottom: 15px; }
    .card-financeiro { background-color: #ffffff; padding: 15px; border-radius: 8px; border-left: 5px solid #2E7D32; box-shadow: 0px 2px 4px rgba(0,0,0,0.05); }
    </style>
""", unsafe_allow_html=True)

# 2. INICIALIZAÇÃO DOS BANCOS DE DADOS EM MEMÓRIA
if "catalogo" not in st.session_state:
    st.session_state.catalogo = pd.DataFrame(columns=["id", "marca", "modelo", "ano", "preco_cliente", "preco_loja", "foto", "obs_interna"])

if "meus_carros" not in st.session_state:
    st.session_state.meus_carros = pd.DataFrame(columns=["id", "marca", "modelo", "ano", "custo_aquisicao", "custo_preparacao", "preco_venda", "foto", "status"])

if "historico_vendas" not in st.session_state:
    st.session_state.historico_vendas = pd.DataFrame(columns=["data", "veiculo", "tipo", "receita_bruta", "custo_total", "lucro_comissao"])

if "id_contador" not in st.session_state:
    st.session_state.id_contador = 1

# 3. MENU LATERAL DE NAVEGAÇÃO
with st.sidebar:
    st.title("🚗 Starcar Pro")
    st.markdown("---")
    menu_principal = st.selectbox("Navegar para:", ["🔍 Catálogo de Parceiros", "👤 Meu Estoque Próprio", "💰 Meu Caixa & Comissões", "⚙️ Cadastros / Baixas"])
    st.markdown("---")
    modo_seguro = st.toggle("Modo Cliente (Esconder dados internos)", value=False)

# 4. TELA: CATÁLOGO DE PARCEIROS
if menu_principal == "🔍 Catálogo de Parceiros":
    st.title("🔍 Catálogo de Terceiros / Repasses")
    busca = st.text_input("Buscar veículo...").upper()
    
    if st.session_state.catalogo.empty:
        st.info("Nenhum carro de parceiro cadastrado ainda.")
    else:
        for _, carro in st.session_state.catalogo.iterrows():
            if busca and (busca not in carro["marca"] and busca not in carro["modelo"]):
                continue
            with st.container(border=True):
                col_img, col_txt = st.columns([1.2, 1.8])
                with col_img:
                    st.image(carro["foto"], use_container_width=True)
                with col_txt:
                    st.subheader(f"{carro['marca']} {carro['modelo']}")
                    st.markdown(f"**Ano:** {carro['ano']}")
                    st.markdown(f"### **R$ {carro['preco_cliente']:,.2f}**".replace(",", "X").replace(".", ",").replace("X", "."))
                    
                    if not modo_seguro:
                        with st.expander("👁️ Detalhes Confidenciais da Loja"):
                            lucro = carro['preco_cliente'] - carro['preco_loja']
                            st.write(f"**Custo Loja:** R$ {carro['preco_loja']:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."))
                            st.markdown(f"**Sua Margem:** <span style='color:green;font-weight:bold;'>R$ {lucro:,.2f}</span>", unsafe_allow_html=True)
                            st.write(f"**Obs:** {carro['obs_interna']}")

# 5. TELA: MEU ESTOQUE PRÓPRIO
elif menu_principal == "👤 Meu Estoque Próprio":
    st.title("👤 Meus Carros (Investimento Próprio)")
    st.markdown("Veículos comprados por você para revenda.")
    
    estoque_proprio = st.session_state.meus_carros[st.session_state.meus_carros["status"] == "Disponível"]
    
    if estoque_proprio.empty:
        st.info("Você não tem carros próprios em estoque no momento.")
    else:
        for _, carro in estoque_proprio.iterrows():
            with st.container(border=True):
                col_img, col_txt = st.columns([1.2, 1.8])
                with col_img:
                    st.image(carro["foto"], use_container_width=True)
                with col_txt:
                    st.subheader(f"{carro['marca']} {carro['modelo']}")
                    st.markdown(f"**Ano:** {carro['ano']}")
                    st.markdown(f"### **R$ {carro['preco_venda']:,.2f}**".replace(",", "X").replace(".", ",").replace("X", "."))
                    
                    if not modo_seguro:
                        with st.expander("👁️ Meus Custos Internos"):
                            total_custo = carro['custo_aquisicao'] + carro['custo_preparacao']
                            lucro_estimado = carro['preco_venda'] - total_custo
                            st.write(f"**Pago no Carro:** R$ {carro['custo_aquisicao']:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."))
                            st.write(f"**Gasto com Preparação:** R$ {carro['custo_preparacao']:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."))
                            st.markdown(f"**Custo Total:** R$ {total_custo:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."))
                            st.markdown(f"**Lucro Estimado:** <span style='color:blue;font-weight:bold;'>R$ {lucro_estimado:,.2f}</span>", unsafe_allow_html=True)

# 6. TELA: MEU CAIXA & COMISSÕES
elif menu_principal == "💰 Meu Caixa & Comissões":
    st.title("💰 Painel Financeiro & Ganhos")
    st.markdown("Histórico detalhado de comissões de lojistas e lucro de carros próprios.")
    st.markdown("---")
    
    if st.session_state.historico_vendas.empty:
        st.warning("Nenhuma venda realizada ou registrada ainda.")
    else:
        df_fin = st.session_state.historico_vendas
        total_comissoes = df_fin[df_fin["tipo"] == "Comissão (Parceiro)"]["lucro_comissao"].sum()
        total_lucro_proprio = df_fin[df_fin["tipo"] == "Venda Própria"]["lucro_comissao"].sum()
        faturamento_total = total_comissoes + total_lucro_proprio
        
        c1, c2, c3 = st.columns(3)
        with c1:
            st.metric("Comissões Recebidas", f"R$ {total_comissoes:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."))
        with c2:
            st.metric("Lucro Próprio", f"R$ {total_lucro_proprio:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."))
        with c3:
            st.metric("Ganhos Totais Líquidos", f"R$ {faturamento_total:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."))
            
        st.markdown("### 📋 Extrato de Vendas Detalhado")
        st.dataframe(df_fin, use_container_width=True)

# 7. TELA: CADASTROS E BAIXAS
elif menu_principal == "⚙️ Cadastros / Baixas":
    st.title("⚙️ Gerenciamento do Sistema")
    aba_add, aba_vender = st.tabs(["➕ Adicionar Carros", "🤝 Registrar Venda / Baixa"])
    
    with aba_add:
        tipo_cadastro = st.selectbox("Onde cadastrar?", ["Catálogo de Parceiro (Repasse/Comissão)", "Meu Estoque Próprio"])
        
        with st.form("cadastro_geral", clear_on_submit=True):
            m = st.text_input("Marca").upper()
            mod = st.text_input("Modelo/Versão").upper()
            a = st.text_input("Ano (Ex: 2015/2015)")
            f = st.text_input("Link da Foto (URL)", value="https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=500")
            
            if tipo_cadastro == "Catálogo de Parceiro (Repasse/Comissão)":
                p_loja = st.number_input("Preço de Custo (Loja) R$", min_value=0.0)
                p_cli = st.number_input("Preço para Cliente R$", min_value=0.0)
                obs = st.text_area("Observações (Quem é o dono, detalhes mecânicos)")
            else:
                c_aq = st.number_input("Preço de Compra R$", min_value=0.0)
                c_prep = st.number_input("Gasto com Preparação R$", min_value=0.0)
                p_cli = st.number_input("Preço de Venda Pretendido R$", min_value=0.0)
                obs = "Carro Próprio"
                
            btn_salvar = st.form_submit_button("Salvar Veículo")
            
            if btn_salvar and m and mod:
                if tipo_cadastro == "Catálogo de Parceiro (Repasse/Comissão)":
                    novo = pd.DataFrame([{"id": st.session_state.id_contador, "marca": m, "modelo": mod, "ano": a, "preco_cliente": p_cli, "preco_loja": p_loja, "foto": f, "obs_interna": obs}])
                    st.session_state.catalogo = pd.concat([st.session_state.catalogo, novo], ignore_index=True)
                else:
                    novo = pd.DataFrame([{"id": st.session_state.id_contador, "marca": m, "modelo": mod, "ano": a, "custo_aquisicao": c_aq, "custo_preparacao": c_prep, "preco_venda": p_cli, "foto": f, "status": "Disponível"}])
                    st.session_state.meus_carros = pd.concat([st.session_state.meus_carros, novo], ignore_index=True)
                st.session_state.id_contador += 1
                st.success("Adicionado com sucesso!")

    with aba_vender:
        st.subheader("Dar baixa em veículo vendido")
        origem_venda = st.selectbox("De onde é o carro vendido?", ["Catálogo de Parceiro", "Meu Estoque Próprio"])
        
        if origem_venda == "Catálogo de Parceiro" and not st.session_state.catalogo.empty:
            ops = {f"{r['marca']} {r['modelo']}": r['id'] for _, r in st.session_state.catalogo.iterrows()}
            escolha = st.selectbox("Selecione o carro parceiro vendido:", list(ops.keys()))
            valor_final_venda = st.number_input("Por quanto você fechou a venda? R$", min_value=0.0)
            
            if st.button("Confirmar Venda Parceiro", type="primary"):
                id_carro = ops[escolha]
                carro_dados = st.session_state.catalogo[st.session_state.catalogo["id"] == id_carro].iloc[0]
                lucro_real = valor_final_venda - carro_dados["preco_loja"]
                nova_venda = pd.DataFrame([{"data": "Hoje", "veiculo": escolha, "tipo": "Comissão (Parceiro)", "receita_bruta": valor_final_venda, "custo_total": carro_dados["preco_loja"], "lucro_comissao": lucro_real}])
                st.session_state.historico_vendas = pd.concat([st.session_state.historico_vendas, nova_venda], ignore_index=True)
                st.session_state.catalogo = st.session_state.catalogo[st.session_state.catalogo["id"] != id_carro]
                st.success("Venda registrada e comissão guardada no caixa!")
                st.rerun()
                
        elif origem_venda == "Meu Estoque Próprio" and not st.session_state.meus_carros[st.session_state.meus_carros["status"] == "Disponível"].empty:
            est_disp = st.session_state.meus_carros[st.session_state.meus_carros["status"] == "Disponível"]
            ops = {f"{r['marca']} {r['modelo']}": r['id'] for _, r in est_disp.iterrows()}
            escolha = st.selectbox("Selecione o seu carro vendido:", list(ops.keys()))
            valor_final_venda = st.number_input("Valor real de fechamento da venda R$", min_value=0.0)
            
            if st.button("Confirmar Venda Própria", type="primary"):
                id_carro = ops[escolha]
                carro_dados = st.session_state.meus_carros[st.session_state.meus_carros["id"] == id_carro].iloc[0]
                custo_total = carro_dados["custo_aquisicao"] + carro_dados["custo_preparacao"]
                lucro_liquido = valor_final_venda - custo_total
                nova_venda = pd.DataFrame([{"data": "Hoje", "veiculo": escolha, "tipo": "Venda Própria", "receita_bruta": valor_final_venda, "custo_total": custo_total, "lucro_comissao": lucro_liquido}])
                st.session_state.historico_vendas = pd.concat([st.session_state.historico_vendas, nova_venda], ignore_index=True)
                st.session_state.meus_carros.loc[st.session_state.meus_carros["id"] == id_carro, "status"] = "Vendido"
                st.success("Parabéns pela venda! Lucro computado no painel.")
                st.rerun()
        else:
            st.info("Nenhum veículo disponível para baixa nesta categoria.")
