Require config.
Require Import config_tactics.

Require Import syntax. (* The syntax of ett/ptt. *)
Require Import tt.

Require ptt ett ett_sanity.
Require pxtt eitt.
Require ctt.
Require Import eval.
Require Import hml.

Section Translation.

Axiom cheating : forall A : Type, A.
Ltac todo := apply cheating.

Structure is_ctx_translation G G' : Type := {
  is_ctx_hml : hml_context G G' ;
  is_ctx_der : eitt.isctx (eval_ctx G')
}.

Structure is_type_translation G' A A' : Type := {
  is_type_hml : hml_type A A';
  is_type_der : eitt.istype (eval_ctx G') (eval_type A')
}.

Structure is_term_translation G' A' u u' : Type := {
  is_term_hml : hml_term u u' ;
  is_term_der : eitt.isterm (eval_ctx G') (eval_term u') (eval_type A')
}.

Definition translation_coherence A G' A' :=
  forall (G'' : ctt.context)
         (crc : coerce.context_coercion (eval_ctx G') (eval_ctx G'')),
  forall A'', is_type_translation G'' A A'' -> coerce.type_coercion crc (eval_type A') (eval_type A'').

Fixpoint translate_isctx {G} (D : pxtt.isctx G) {struct D} :
  { G' : ctt.context & is_ctx_translation G G' }

with translate_istype {G A} (D : pxtt.istype G A) {struct D} :
  forall G', is_ctx_translation G G' ->
  { A' : ctt.type & is_type_translation G' A A' * translation_coherence A G' A'}%type

with translate_isterm {G A u} (D : pxtt.isterm G u A) {struct D} :
  forall G', is_ctx_translation G G' ->
  forall A', is_type_translation G' A A' ->
  { u' : ctt.term & is_term_translation G' A' u u' }
.

Proof.
  (* translate_isctx *)
  - { destruct D ; doConfig.

      (* CtxEmpty *)
      - { exists ctt.ctxempty.
          split.
          - constructor.
          - capply CtxEmpty.
        }

      (* CtxExtend *)
      - { destruct (translate_isctx G i) as [G'' TGG''].
          destruct (translate_istype G A i0 G'' TGG'') as [A'' [[? ?] ?]].
          exists (ctt.ctxextend G'' A'').
          destruct TGG''.
          split.
          - now constructor.
          - now capply CtxExtend.
        }
  }

  (* translate_istype *)
  - { destruct D ; doConfig.

      (* TyCtxConv *)
      - { (* Need: translate_eqctx *)
          todo.
        }

      (* TySubst *)
      - { (* Need: translate_issubst *)
          todo.
        }

      (* TyProd *)
      - { intros G' TGG'.
          pose (TGG'_hml := is_ctx_hml _ _ TGG').
          destruct (translate_istype G A i G' TGG') as [A' [[? ?] ?]].
          assert (TGAG'A' : is_ctx_translation (ctxextend G A) (ctt.ctxextend G' A')).
          { split.
            - now apply hml_ctxextend.
            - now capply CtxExtend. }
          destruct (translate_istype (ctxextend G A) B D (ctt.ctxextend G' A') TGAG'A')
            as [B' [[? ?] ?]].
          eexists (ctt.Coerce (coerce.ctx_coe_id (eval_ctx G') _) (ctt.Prod A' B')).
          Unshelve. Focus 2.
          { apply TGG'. }
          Unfocus.
          split ; [ split | .. ].
          - now apply hml_Coerce, hml_Prod.
          - todo.
          - intros G'' crc PiAB'' [hmlPiAB'' DPiAB''].
            inversion hmlPiAB''. inversion X.
            subst. rename A'1 into A''. rename B'0 into B''.
            assert (is_type_translation G'' A A'').
            { split.
              - assumption.
              - (* We need an inversion lemma to apply on DPiAB'' *)
                todo.
            }
            pose proof (t G'' crc A'' X2).
            assert (
              coerce.context_coercion (eval_ctx (ctt.ctxextend G' A'))
                                      (eval_ctx (ctt.ctxextend G'' A''))
            ).
            { (* We basically want to extend crc by H *)
              todo.
            }
            assert (is_type_translation (ctt.ctxextend G'' A'') B B'').
            { split.
              - assumption.
              - (* Inversion lemma *)
                todo.
            }
            pose proof (t0 (ctt.ctxextend G'' A'') X4 B'' X5).
            refine {| coerce.type_coe_act := _ ;
                      coerce.type_coe_inv := _ |}.
            1:shelve.
            + ceapply TermAbs.
              ceapply TermSubst.
              * ceapply SubstWeak.
                ceapply TySubst.
                -- apply (coerce.ctx_coe_issubst_inv crc).
                -- simpl. unfold coerce.act_type.
                   ceapply TySubst.
                   ++ capply SubstId. now destruct TGG'.
                   ++ ceapply TyProd.
                      now destruct X5.
              * ceapply TermSubst.
                -- apply (coerce.ctx_coe_issubst_inv crc0).


(* split. *)
(*               * (* It has to go from crc(Prod A' B') to PiAB'' in G'' *) *)
(*                 (* Somehow it feels like the goal should be more than term. *)
(*                    If we had existential statements instead we would be *)
(*                    able to have tactics. *) *)
(*                 simple refine ( *)
(*                   lam (ctt.act_type crc (eval_type (ctt.Prod A' B'))) *)
(*                       (Subst (eval_type (ctt.Prod A'' B'')) *)
(*                              (sbweak (ctt.act_type crc (eval_type (ctt.Prod A' B'))))) *)
(*                       _ *)
(*                 ). *)
(*                 (* simple refine ( *) *)
(*                 (*   lam _ _ _ *) *)
(*                 (* ). *) *)
(*                 todo. *)
(*               * (* It has to go from crc^-1(PiAB'') to Prod A' B' in G' *) *)
(*                 todo. *)
        }

      (* TyId *)
      - { intros G' TGG'.
          destruct (translate_istype G A i0 G' TGG') as [A' [? ?]].
          destruct (translate_isterm G A u i1 G' TGG' A' i3) as [u' [ ?]].
          destruct (translate_isterm G A v i2 G' TGG' A' i3) as [v' [? ?]].
          destruct i3. destruct TGG'.
          exists (ctt.Id A' u' v') ; split.
          + split.
            * now apply hml_Id.
            * now apply TyId.
          + todo.
        }

      (* TyEmpty *)
      - { intros G' [? ?].
          exists ctt.Empty ; split.
          - split.
            + constructor.
            + now capply TyEmpty.
          - todo.
        }

      (* TyUnit *)
      - { intros G' [? ?].
          exists ctt.Unit ; split.
          - split.
            + constructor.
            + now capply TyUnit.
          - todo.
        }

      (* TyBool *)
      - { intros G' [? ?].
          exists ctt.Bool ; split.
          - split.
            + constructor.
            + now apply TyBool.
          - todo.
        }
    }

  (* translate_isterm *)
  - { destruct D ; doConfig.

      (* TermTyConv *)
      - { (* Need: translate_eqtype *)
          todo.
        }

      (* TermCtxConv *)
      - { (* Need: translate_eqctx *)
          todo.
        }

      (* TermSubst *)
      - { (* Need: translate_issubst *)
          todo.
        }

      (* TermVarZero *)
      - { intros GA' [HGAGA' ?] Aw' TAwAw'.
          (* This is not var 0 in the genral case! *)
          inversion HGAGA'. subst. rename H1 into HGG'. rename H3 into HAA'.
          (* We need to have a coercion between A'[w] and Aw'. *)
          todo.
        }

      (* TermVarSucc *)
      - { intros GB' [HGB D'] Aw' [HAw D''].

          inversion HGB. subst. rename H1 into HG. rename H3 into HB.
          rename A' into B'.

          inversion HAw.

          - subst. rename H1 into HA. rename H3 into Hw.

            inversion Hw. subst. rename A'0 into B''. rename H0 into HB'.
            + (* We still have a coherence problem as we have two translations
                 of B. *)
              todo.
            + todo.

          - todo.
        }

      (* TermAbs *)
      - { intros G' [HG D'] PiAB [HPiAB D''].

          inversion HPiAB.
          (* All those keep branching, that was, one of the reasons, we were
             always having a coercion, may it be the identity. *)
          (* I'm fine with keeping things as they are but we probably should
             have a lemma not to deal with so many cases and only consider
             the coerced case? *)
          - subst. rename H1 into HA. rename H3 into HB.
            todo.
          - todo.
        }

      (* TermApp *)
      - { (* Coherence problem *)
          todo.
        }

      (* TermRefl *)
      - { intros G' TGG' IdAuu' [HIdA' ?].
          inversion HIdA'.
          - subst. todo.
          - todo.


          (* destruct (translate_isterm G A u D G' TGG'). *)
          (* exists G'. exists (ctt.Id A' u' u'). exists (ctt.refl A' u'). *)
          (* repeat split. *)
          (* - assumption. *)
          (* - (* Problem of homology *) *)
          (*   todo. *)
          (* - (* Problem of homology *) *)
          (*   todo. *)
          (* - now capply TermRefl. *)
        }

      (* TermJ *)
      - { (* Likely coherence and homology issues *)
          todo.
        }

      (* TermExfalso *)
      - { (* Coherence problem *)
          todo.
        }

      (* TermUnit *)
      - { destruct (translate_isctx G i) as [G' [? ?]].
          exists G'. exists ctt.Unit. exists ctt.unit.
          repeat split.
          - assumption.
          - (* Homology issue *)
            todo.
          - (* Homology issue *)
            todo.
          - now capply TermUnit.
        }

      (* TermTrue *)
      - { destruct (translate_isctx G i) as [G' [? ?]].
          exists G'. exists ctt.Bool. exists ctt.true.
          repeat split.
          - assumption.
          - (* Homology issue *)
            todo.
          - (* Homology issue *)
            todo.
          - now capply TermTrue.
        }

      (* TermFalse *)
      - { destruct (translate_isctx G i) as [G' [? ?]].
          exists G'. exists ctt.Bool. exists ctt.false.
          repeat split.
          - assumption.
          - (* Homology issue *)
            todo.
          - (* Homology issue *)
            todo.
          - now capply TermFalse.
        }

      (* TermCond *)
      - { (* Coherence problem *)
          todo.
        }
    }

Defined.

End Translation.
