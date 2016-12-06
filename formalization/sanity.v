Require Import ett.

Fixpoint TyIdInversion {G A u v} (H : istype G (Id A u v)) {struct H} :
  istype G A * isterm G u A * isterm G v A.
Proof.
  inversion H.

  - { split ; [split | idtac].
      - apply (@TyCtxConv G0 G).
        + now apply TyIdInversion with (u := u) (v := v).
        + assumption.
      - apply (@TermCtxConv G0 G).
        + now apply TyIdInversion with (u := u) (v:= v).
        + assumption.
      - apply (@TermCtxConv G0 G).
        + now apply TyIdInversion with (u := u) (v:= v).
        + assumption. }

  - { split ; [split | idtac].
      - assumption.
      - assumption.
      - assumption. }

Defined.

(* Tactic to apply one the induction hypotheses. *)
Ltac ih :=
  match goal with
  | f : forall G D sbs, issubst sbs G D -> isctx G * isctx D ,
    _ : issubst ?sbs ?G ?D
    |- _ => now apply (f G D sbs)
  | f : forall G A, istype G A -> isctx G ,
    _ : istype ?G ?A
    |- _ => now apply (f G A)
  | f : forall G A u, isterm G u A -> isctx G * istype G A ,
    _ : isterm ?G ?u ?A |- _ => now apply (f G A u)
  | f : forall G D, eqctx G D -> isctx G * isctx D ,
    _ : eqctx ?G ?D |- _ => now apply (f G D)
  | f : forall G D sbs sbt,
        eqsubst sbs sbt G D ->
        isctx G * isctx D * issubst sbs G D * issubst sbt G D ,
    _ : eqsubst ?sbs ?sbt ?G ?D |- _ => now apply (f G D sbs sbt)
  | f : forall G A B, eqtype G A B -> isctx G * istype G A * istype G B ,
    _ : eqtype ?G ?A ?B |- _ => now apply (f G A B)
  | f : forall G u v A,
        eqterm G u v A -> isctx G * istype G A * isterm G u A * isterm G v A ,
    _ : eqterm ?G ?u ?v ?A |- _ => now apply (f G u v A)
  | _ => fail
  end.

(* Magic tactic. *)
Ltac magicn n :=
  match eval compute in n with
  | 0 => ih || easy
  | S ?n => magicn n || (constructor ; magicn n)
  end.

Ltac magic := magicn (S (S 0)).

(* For admitting purposes *)
Lemma todo : False.
Admitted.


Fixpoint sane_issubst {G D sbs} (H : issubst sbs G D) {struct H} :
       isctx G * isctx D

with sane_istype {G A} (H : istype G A) {struct H} :
       isctx G

with sane_isterm {G A u} (H : isterm G u A) {struct H} :
       isctx G * istype G A

with sane_eqctx {G D} (H : eqctx G D) {struct H} :
       isctx G * isctx D

with sane_eqsubst {G D sbs sbt} (H : eqsubst sbs sbt G D) {struct H} :
       isctx G * isctx D * issubst sbs G D * issubst sbt G D

with sane_eqtype {G A B} (H : eqtype G A B) {struct H} :
       isctx G * istype G A * istype G B

with sane_eqterm {G u v A} (H : eqterm G u v A) {struct H} :
       isctx G * istype G A * isterm G u A * isterm G v A.

Proof.
  (****** sane_issubst ******)
  - destruct H ; split ; try magic.

    (* SubstShift *)
    constructor ; try magic.
    now apply @TySubst with (D := D).

  (****** sane_istype ******)
  - destruct H ; magic.

  (****** sane_isterm ******)
  - destruct H; split ; try magic.

    (* TermCtxConv *)
    + apply (@TyCtxConv G D A) ; magic.

    (* TermSubst *)
    + apply @TySubst with (D := D) ; magic.

    (* TermVarZero *)
    + apply (@TySubst _ G) ; magic.

    (* TermVarSucc *)
    + apply (@TySubst _ G) ; magic.

    (* TermApp *)
    + apply @TySubst with (D := ctxextend G A) ; magic.

    (* TermJ *)
    + { apply @TySubst with (D := ctxextend G (Id A u v)).
        - now apply SubstZero.
        - { apply @TyCtxConv
            with (G :=
                    ctxextend G
                              (Subst
                                 (Id
                                    (Subst A (sbweak G A))
                                    (subst u (sbweak G A))
                                    (var 0))
                                 (sbzero G A v))).
            - { eapply TySubst.
                - eapply SubstShift.
                  + now eapply SubstZero.
                  + constructor ; try magic.
                    * { eapply TySubst.
                        - apply SubstWeak. magic.
                        - magic.
                      }
                    * { eapply @TermSubst.
                        - magic.
                        - magic.
                      }
                - magic.
              }
            - apply EqCtxExtend.
              + apply CtxRefl. magic.
              + eapply EqTyTrans.
                * { eapply EqTySubstId.
                    - magic.
                    - eapply TySubst.
                      + magic.
                      + magic.
                    - eapply TermSubst.
                      + magic.
                      + magic.
                    - magic.
                  }
                * { apply CongId.
                    - apply EqTyWeakZero.
                      + magic.
                      + magic.
                    - eapply EqTyConv.
                      + eapply EqSubstWeakZero.
                        * eassumption.
                        * assumption.
                      + apply EqTySym. apply EqTyWeakZero.
                        * magic.
                        * assumption.
                    - eapply EqTyConv.
                      + apply EqSubstZeroZero. magic.
                      + apply EqTySym. apply EqTyWeakZero ; magic.
                  }
          }
      }

    (* TermCond *)
    + apply @TySubst with (D := ctxextend G Bool) ; magic.

  (****** sane_eqctx ******)
  - destruct H; split ; try magic.

    (* EqCtxExtend *)
    apply CtxExtend.
    + magic.
    + eapply TyCtxConv.
      * magic.
      * magic.

  (****** sane_eqsubst ******)
  - destruct H; (split ; [split ; [split | idtac] | idtac]) ; try magic.

    (* CongSubstZero *)
    + eapply SubstCtxConv.
      * eapply SubstZero.
        { eapply TermTyConv.
          - magic.
          - magic.
        }
      * magic.
      * apply EqCtxExtend ; magic.

    (* CongSubstWeak *)
    + { eapply SubstCtxConv.
        - eapply SubstWeak.
          eapply TyCtxConv.
          + magic.
          + assumption.
        - apply CtxSym.
          apply EqCtxExtend.
          + assumption.
          + assumption.
        - now apply CtxSym.
      }

    (* CongSubstShift *)
    + { constructor.
        - magic.
        - eapply TySubst.
          + magic.
          + magic.
      }
    + { eapply SubstCtxConv.
        - eapply SubstShift.
          + eapply SubstCtxConv.
            * magic.
            * assumption.
            * apply CtxRefl.
              magic.
          + magic.
        - apply CtxSym. apply EqCtxExtend.
          + magic.
          + eapply CongTySubst.
            * eassumption.
            * assumption.
        - constructor. magic.
      }

    (* CongSubstComp *)
    + eapply SubstComp ; magic.
    + eapply SubstComp ; magic.
    + eapply SubstCtxConv ; magic.
    + eapply SubstCtxConv ; magic.


  (****** sane_eqtype ******)
  - destruct H; (split ; [split | idtac]) ; try magic.

    (* EqTyCtxConv *)
    + apply @TyCtxConv with (G := G) ; magic.
    + apply @TyCtxConv with (G := G) ; magic.

    (* EqTyIdSubst *)
    + eapply TySubst.
      * constructor. ih.
      * assumption.

    (* EqTySubstComp *)
    + { eapply TySubst.
        - eassumption.
        - eapply TySubst.
          + eassumption.
          + assumption.
      }
    + { eapply TySubst.
        - eapply SubstComp.
          + eassumption.
          + eassumption.
        - assumption.
      }

    (* EqTyWeakNat *)
    + constructor.
      * magic.
      * now apply @TySubst with (D := D).
    + eapply TySubst.
      * eapply SubstShift; eassumption.
      * eapply TySubst.
        { eapply SubstWeak; eassumption. }
        { assumption. }
    + eapply TySubst.
      * eapply SubstWeak.
        now apply @TySubst with (D := D).
      * now apply @TySubst with (D := D).

    (* EqTyWeakZero *)
    + eapply TySubst.
      * now eapply SubstZero.
      * eapply TySubst.
        { apply SubstWeak. ih. }
        { assumption. }

    (* EqTyShiftZero *)
    + eapply TySubst.
      * apply SubstZero.
        now apply @TermSubst with (D := D).
      * eapply TySubst.
        { eapply SubstShift.
          - eassumption.
          - ih.
        }
        { assumption. }
    + eapply TySubst.
      * eassumption.
      * eapply TySubst.
        { now apply SubstZero. }
        { assumption. }

    (* EqTyCongZero *)
    + eapply TySubst ; magic.
    + eapply TySubst.
      * apply SubstZero.
        apply @TermTyConv with (A := A1).
        { ih. }
        { assumption. }
      * eapply @TyCtxConv.
        { ih. }
        { apply EqCtxExtend ; magic. }

    (* EqTySubstProd *)
    + eapply TySubst.
      * eassumption.
      * now apply TyProd.
    + constructor.
      * eapply TySubst.
        { eassumption. }
        { assumption. }
      * eapply TySubst.
        { eapply SubstShift. eassumption. assumption. }
        { assumption. }

    (* EqTySubstId *)
    + eapply TySubst.
      * eassumption.
      * now apply TyId.
    + constructor.
      * now apply @TySubst with (D := D).
      * now apply @TermSubst with (D := D).
      * now apply @TermSubst with (D := D).

    (* EqTySubstEmpty *)
    + eapply TySubst.
      * eassumption.
      * apply TyEmpty. ih.

    (* EqTySubstUnit *)
    + eapply TySubst.
      * eassumption.
      * apply TyUnit. ih.

    (* EqTySubstBool *)
    + eapply TySubst.
      * eassumption.
      * apply TyBool. ih.

    (* CongProd *)
    + constructor.
      * ih.
      * apply @TyCtxConv with (G := ctxextend G A1).
        { ih. }
        { apply EqCtxExtend.
          - magic.
          - magic.
        }

    (* CongId *)
    + constructor ; try magic.
      * apply @TermTyConv with (A := A).
        { ih. }
        { assumption. }
      * apply @TermTyConv with (A := A).
        { ih. }
        { assumption. }

    (* CongTySubst *)
    + apply @TySubst with (D := D).
      * ih.
      * ih.
    + apply @TySubst with (D := D).
      * ih.
      * ih.


  (****** sane_eqterm ******)
  - destruct H ;
    (split ; [(split ; [split | idtac]) | idtac]) ; try magic.

    (* EqTyConv *)
    + eapply TermTyConv.
      * ih.
      * assumption.
    + eapply TermTyConv.
      * ih.
      * assumption.

    (* EqCtxConv *)
    + eapply TyCtxConv.
      * ih.
      * assumption.
    + eapply TermCtxConv.
      * ih.
      * assumption.
    + eapply TermCtxConv.
      * ih.
      * assumption.

    (* EqIdSubst *)
    + { eapply TermTyConv.
        - eapply TermSubst.
          + constructor. ih.
          + eassumption.
        - apply EqTyIdSubst. ih.
      }
    + { eapply TySubst.
        - eapply SubstComp.
          + eassumption.
          + eassumption.
        - ih.
      }

    (* EqSubstComp *)
    + { eapply TermTyConv.
        - eapply TermSubst.
          + eassumption.
          + eapply TermSubst.
            * eassumption.
            * eassumption.
        - eapply EqTySubstComp.
          + ih.
          + eassumption.
          + assumption.
      }
    + { eapply TermSubst.
        - eapply SubstComp.
          + eassumption.
          + eassumption.
        - assumption.
      }

    (* EqSubstWeak *)
    + apply @TySubst with (D := G).
      * now apply SubstWeak.
      * ih.
    + apply @TermSubst with (D := G).
      * now apply SubstWeak.
      * assumption.

    (* EqSubstZeroZero *)
    + eapply TermTyConv.
      * { eapply TermSubst.
          - now apply SubstZero.
          - apply TermVarZero.
            ih. }
      * { apply EqTyWeakZero.
          - ih.
          - assumption. }

    (* EqSubstZeroSucc *)
    + eapply TermTyConv.
      * { eapply TermSubst.
          - now apply SubstZero.
          - apply @TermVarSucc with (A := A).
            + assumption.
            + ih. }
      * { apply EqTyWeakZero.
          - ih.
          - assumption. }

    (* EqSubstShiftZero *)
    + constructor ; try magic.
      now apply @TySubst with (D := D).
    + { eapply TySubst.
        - apply SubstWeak.
          now apply @TySubst with (D := D).
        - now apply @TySubst with (D := D). }
    + { eapply TermTyConv.
        - eapply TermSubst.
          + eapply SubstShift.
            * eassumption.
            * assumption.
          + now apply TermVarZero.
        - now apply EqTyWeakNat. }
    + constructor ; try magic.
      now apply @TySubst with (D := D).

    (* EqSubstShiftSucc *)
    + constructor ; try magic.
      now apply @TySubst with (D := D).
    + { eapply TySubst.
        - apply SubstWeak.
          now apply @TySubst with (D := D).
        - apply @TySubst with (D := D).
          + assumption.
          + ih. }
    + { eapply TermTyConv.
        - eapply TermSubst.
          + eapply SubstShift.
            * eassumption.
            * assumption.
          + eapply TermVarSucc.
            * eassumption.
            * assumption.
        - apply EqTyWeakNat.
          + assumption.
          + assumption.
          + ih. }
    + { eapply TermSubst.
        - apply SubstWeak.
          now apply @TySubst with (D := D).
        - now apply @TermSubst with (D := D). }

    (* EqSubstWeakZero *)
    + { eapply TermTyConv.
        - eapply TermSubst.
          + magic.
          + eapply TermSubst.
            * magic.
            * eassumption.
        - apply EqTyWeakZero.
          + magic.
          + magic.
      }

    (* EqSubstWeakNat *)
    + constructor ; try magic.
      now apply @TySubst with (D := D).
    + eapply TySubst.
      * eapply SubstWeak. now apply @TySubst with (D := D).
      * apply @TySubst with (D := D) ; magic.
    + { eapply TermTyConv.
        - eapply TermSubst.
          + eapply SubstShift ; eassumption.
          + eapply TermSubst.
            * eapply SubstWeak. assumption.
            * eassumption.
        - apply EqTyWeakNat ; magic.
      }
    + { eapply TermSubst.
        - eapply SubstWeak. eapply TySubst.
          + eassumption.
          + assumption.
        - eapply TermSubst ; eassumption.
      }

    (* EqSubstAbs *)
    + constructor ; try magic.
      * now apply @TySubst with (D := D).
      * eapply TySubst.
        { now apply @SubstShift with (D := D). }
        { ih. }
    + { eapply TermTyConv.
        - apply @TermSubst with (D := D).
          + assumption.
          + now apply TermAbs.
        - apply @EqTySubstProd with (D := D).
          + assumption.
          + assumption.
          + ih. }
    + constructor ; try magic.
      * now apply @TySubst with (D := D).
      * { eapply TermSubst.
          - eapply SubstShift.
            + eassumption.
            + assumption.
          - assumption.
        }

    (* EqSubstApp *)
    + { eapply TySubst.
        - eassumption.
        - eapply TySubst.
          + now apply SubstZero.
          + assumption. }
    + { apply @TermSubst with (D := D).
        - assumption.
        - now apply TermApp. }
    + { eapply TermTyConv.
        - apply TermApp.
          + { eapply TySubst.
              - eapply SubstShift.
                + eassumption.
                + ih.
              - assumption. }
          + { eapply TermTyConv.
              - apply @TermSubst with (D := D).
                + assumption.
                + eassumption.
              - eapply EqTySubstProd.
                + eassumption.
                + ih.
                + assumption. }
          + now apply @TermSubst with (D := D).
        - now apply EqTyShiftZero. }

    (* EqSubstRefl *)
    + constructor ; try magic.
      * apply @TySubst with (D := D) ; magic.
      * now apply @TermSubst with (D := D).
      * now apply @TermSubst with (D := D).
    + { eapply TermTyConv.
        - apply @TermSubst with (D := D).
          + assumption.
          + now apply TermRefl.
        - apply @EqTySubstId with (D := D).
          + assumption.
          + ih.
          + assumption.
          + assumption. }
    + constructor ; try magic.
      now apply @TermSubst with (D := D).

    (* EqSubstJ *)
    + { eapply TySubst.
        - eassumption.
        - eapply TySubst.
          + eapply SubstZero. assumption.
          + { eapply TyCtxConv.
              - eapply TySubst.
                + eapply SubstShift.
                  * eapply SubstZero. assumption.
                  * { apply TyId.
                      - eapply TySubst.
                        + eapply SubstWeak. magic.
                        + magic.
                      - eapply TermSubst.
                        + eapply SubstWeak. magic.
                        + assumption.
                      - magic.
                    }
                + assumption.
              - apply EqCtxExtend ; try magic.
                eapply EqTyTrans.
                + { eapply EqTySubstId.
                    - eapply SubstZero. assumption.
                    - eapply TySubst.
                      + eapply SubstWeak. magic.
                      + magic.
                    - eapply TermSubst.
                      + eapply SubstWeak. magic.
                      + assumption.
                    - constructor. magic.
                  }
                + { apply CongId.
                    - apply EqTyWeakZero.
                      + magic.
                      + assumption.
                    - eapply EqTyConv.
                      + eapply EqSubstWeakZero.
                        * eassumption.
                        * assumption.
                      + apply EqTySym. apply EqTyWeakZero.
                        * magic.
                        * assumption.
                    - eapply EqTyConv.
                      + apply EqSubstZeroZero. magic.
                      + apply EqTySym. apply EqTyWeakZero ; magic.
                  }
            }
      }
    + { eapply TermSubst.
        - eassumption.
        - magic.
      }
    + { eapply TermTyConv.
        - constructor.
          + apply @TySubst with (D := D) ; assumption.
          + apply @TermSubst with (D := D) ; assumption.
          + { eapply TyCtxConv.
              - eapply TySubst.
                + { eapply SubstShift.
                    - eapply SubstShift.
                      + eassumption.
                      + magic.
                    - constructor.
                      + eapply TySubst.
                        * eapply SubstWeak. magic.
                        * magic.
                      + eapply TermSubst.
                        * eapply SubstWeak. magic.
                        * assumption.
                      + constructor. magic.
                  }
                + assumption.
              - apply EqCtxExtend.
                { apply CtxRefl. apply CtxExtend.
                  - magic.
                  - eapply TySubst.
                    + eassumption.
                    + magic.
                }
                { eapply EqTyTrans.
                  - eapply EqTySubstId.
                    + eapply SubstShift.
                      * eassumption.
                      * magic.
                    + eapply TySubst.
                      * eapply SubstWeak. magic.
                      * magic.
                    + eapply TermSubst.
                      * eapply SubstWeak. magic.
                      * assumption.
                    + constructor. magic.
                  - apply CongId.
                    + apply EqTyWeakNat ; assumption.
                    + { eapply EqTyConv.
                        - eapply EqSubstWeakNat ; eassumption.
                        - apply EqTySym. apply EqTyWeakNat ; assumption.
                      }
                    + { eapply EqTyConv.
                        - eapply EqSubstShiftZero ; eassumption.
                        - apply EqTySym. apply EqTyWeakNat ; assumption.
                      }
                }
            }
          (* Typing w is hard. *)
          + { eapply TermTyConv.
              - eapply TermSubst ; eassumption.
              - apply EqTySym. eapply EqTyTrans.
                + (* We need to replace the type and term in the last sbzero
                     by their version with the other sbzero substitution. *)
                  eapply @EqTyCongZero
                  with
                    (B1 := Subst
                            (Id (Subst (Subst A sbs) (sbweak G (Subst A sbs)))
                                (subst (subst u sbs) (sbweak G (Subst A sbs)))
                                (var 0))
                            (sbzero G (Subst A sbs) (subst u sbs)))
                    (u2 := subst
                            (refl (Subst (Subst A sbs) (sbweak G (Subst A sbs)))
                                  (subst (subst u sbs) (sbweak G (Subst A sbs)))
                            )
                            (sbzero G (Subst A sbs) (subst u sbs))).
                  * { apply EqTySym. eapply EqTyTrans.
                      - eapply EqTySubstId.
                        + eapply SubstZero. eapply TermSubst ; eassumption.
                        + eapply TySubst.
                          * eapply SubstWeak. eapply TySubst ; eassumption.
                          * eapply TySubst ; eassumption.
                        + eapply TermSubst.
                          * eapply SubstWeak. eapply TySubst ; eassumption.
                          * eapply TermSubst ; eassumption.
                        + apply TermVarZero. eapply TySubst ; eassumption.
                      - apply CongId.
                        + apply EqTyWeakZero.
                          * eapply TySubst ; eassumption.
                          * eapply TermSubst ; eassumption.
                        + apply EqSubstWeakZero.
                          * { eapply TermTyConv.
                              - eapply TermSubst ; eassumption.
                              - apply EqTySym. apply EqTyWeakZero.
                                + eapply TySubst ; eassumption.
                                + eapply TermSubst ; eassumption.
                            }
                          * eapply TermSubst ; eassumption.
                        + { eapply EqTyConv.
                            - eapply EqSubstZeroZero.
                              eapply TermSubst ; eassumption.
                            - apply EqTySym. apply EqTyWeakZero.
                              + eapply TySubst ; eassumption.
                              + eapply TermSubst ; eassumption.
                          }
                    }
                  * { apply EqSym. eapply EqTyConv.
                      - eapply EqTrans.
                        + eapply EqSubstRefl.
                          * eapply SubstZero.
                            eapply TermSubst ; eassumption.
                          * { eapply TermSubst.
                              - eapply SubstWeak.
                                eapply TySubst ; eassumption.
                              - eapply TermSubst ; eassumption.
                            }
                        + { apply CongRefl.
                            - apply EqSubstWeakZero.
                              + eapply TermTyConv.
                                * eapply TermSubst ; eassumption.
                                * apply EqTySym.
                                  { apply EqTyWeakZero.
                                    - eapply TySubst ; eassumption.
                                    - eapply TermSubst ; eassumption.
                                  }
                              + eapply TermSubst ; eassumption.
                            - apply EqTyWeakZero.
                              + eapply TySubst ; eassumption.
                              + eapply TermSubst ; eassumption.
                          }
                      - { apply CongId.
                          - apply EqTyWeakZero.
                            + eapply TySubst ; eassumption.
                            + eapply TermSubst ; eassumption.
                          - apply EqSubstWeakZero.
                            + eapply TermTyConv.
                              * eapply TermSubst ; eassumption.
                              * { apply EqTySym. apply EqTyWeakZero.
                                  - eapply TySubst ; eassumption.
                                  - eapply TermSubst ; eassumption.
                                }
                            + eapply TermSubst ; eassumption.
                          - apply EqSubstWeakZero.
                            + eapply TermTyConv.
                              * eapply TermSubst ; eassumption.
                              * apply EqTySym.
                                { apply EqTyWeakZero.
                                  - eapply TySubst ; eassumption.
                                  - eapply TermSubst ; eassumption.
                                }
                            + eapply TermSubst ; eassumption.
                        }
                    }
                  * { eapply EqTyRefl. eapply TyCtxConv.
                      - eapply TySubst.
                        + eapply SubstShift.
                          * eapply SubstZero. eapply TermSubst ; eassumption.
                          * { apply TyId.
                              - eapply TySubst.
                                + eapply SubstWeak.
                                  eapply TySubst ; eassumption.
                                + eapply TySubst ; eassumption.
                              - eapply TermSubst.
                                + eapply SubstWeak.
                                  eapply TySubst ; eassumption.
                                + eapply TermSubst ; eassumption.
                              - apply TermVarZero.
                                eapply TySubst ; eassumption.
                            }
                        + { eapply TyCtxConv.
                            - eapply TySubst.
                              + eapply SubstShift.
                                * eapply SubstShift ; eassumption.
                                * { apply TyId.
                                    - eapply TySubst.
                                      + eapply SubstWeak. ih.
                                      + ih.
                                    - eapply TermSubst.
                                      + eapply SubstWeak. ih.
                                      + assumption.
                                    - eapply TermVarZero. ih.
                                  }
                              + magic.
                            - apply EqCtxExtend.
                              + apply CtxRefl.
                                apply CtxExtend.
                                * magic.
                                * eapply TySubst ; eassumption.
                              + eapply EqTyTrans.
                                * { eapply EqTySubstId.
                                    - eapply SubstShift ; eassumption.
                                    - eapply TySubst.
                                      + eapply SubstWeak. ih.
                                      + ih.
                                    - eapply TermSubst.
                                      + eapply SubstWeak. ih.
                                      + assumption.
                                    - apply TermVarZero. ih.
                                  }
                                * { apply CongId.
                                    - apply EqTyWeakNat ; magic.
                                    - eapply EqTyConv.
                                      + eapply EqSubstWeakNat ; eassumption.
                                      + apply EqTySym.
                                        apply EqTyWeakNat ; magic.
                                    - eapply EqTyConv.
                                      + eapply EqSubstShiftZero ; eassumption.
                                      + apply EqTySym.
                                        apply EqTyWeakNat ; magic.
                                  }
                          }
                      - { apply EqCtxExtend ; try magic.
                          eapply EqTyTrans.
                          - eapply EqTySubstId.
                            + eapply SubstZero.
                              eapply TermSubst ; eassumption.
                            + eapply TySubst.
                              * eapply SubstWeak.
                                eapply TySubst ; eassumption.
                              * eapply TySubst ; eassumption.
                            + eapply TermSubst.
                              * eapply SubstWeak.
                                eapply TySubst ; eassumption.
                              * eapply TermSubst ; eassumption.
                            + apply TermVarZero.
                              eapply TySubst ; eassumption.
                          - apply CongId.
                            + apply EqTyWeakZero.
                              * eapply TySubst ; eassumption.
                              * eapply TermSubst ; eassumption.
                            + eapply EqTyConv.
                              * { eapply EqSubstWeakZero.
                                  - eapply TermSubst ; eassumption.
                                  - eapply TermSubst ; eassumption.
                                }
                              * apply EqTySym.
                                { apply EqTyWeakZero.
                                  - eapply TySubst ; eassumption.
                                  - eapply TermSubst ; eassumption.
                                }
                            + { eapply EqTyConv.
                                - apply EqSubstZeroZero.
                                  eapply TermSubst ; eassumption.
                                - apply EqTySym.
                                  apply EqTyWeakZero.
                                  + eapply TySubst ; eassumption.
                                  + eapply TermSubst ; eassumption.
                              }
                        }
                    }
                + (* Is this where everything goes wrong? *)
                  (* This actually comes from before! The sbzero that we
                     introduced is ill-typed. It was not before EqyCongZero,
                     but somehow, one the exchanges that we did broke typing
                     by removing one layer of substitution... *)
                  { eapply EqTyTrans.
                    - (* This is the guilty party, the right-hand side we wish
                         to produce is ill-typed. *)
                      eapply EqTyShiftZero.
                      + eapply SubstZero.
                        eapply TermSubst ; eassumption.
                      + { eapply TyCtxConv.
                          - eapply TySubst.
                            + eapply SubstShift.
                              * eapply SubstShift ; eassumption.
                              * { apply TyId.
                                  - eapply TySubst.
                                    + eapply SubstWeak. ih.
                                    + ih.
                                  - eapply TermSubst.
                                    + eapply SubstWeak. ih.
                                    + assumption.
                                  - apply TermVarZero. ih.
                                }
                            + magic.
                          - apply EqCtxExtend.
                            { apply CtxRefl.
                              apply CtxExtend.
                              - magic.
                              - eapply TySubst ; eassumption.
                            }
                            { eapply EqTyTrans.
                              - eapply EqTySubstId.
                                + eapply SubstShift ; eassumption.
                                + eapply TySubst.
                                  * eapply SubstWeak. ih.
                                  * ih.
                                + eapply TermSubst.
                                  * eapply SubstWeak. ih.
                                  * assumption.
                                + apply TermVarZero. ih.
                              - { apply CongId.
                                  - apply EqTyWeakNat ; magic.
                                  - eapply EqTyConv.
                                    + eapply EqSubstWeakNat.
                                      * assumption.
                                      * ih.
                                      * eassumption.
                                    + apply EqTySym. apply EqTyWeakNat ; magic.
                                  - eapply EqTyConv.
                                    + eapply EqSubstShiftZero ; eassumption.
                                    + apply EqTySym. apply EqTyWeakNat ; magic.
                                }
                            }
                        }
                      + (* This is false... *)
                        { eapply TermTyConv.
                          - eapply TermRefl.
                            eapply TermSubst.
                            + eapply SubstWeak.
                              eapply TySubst ; eassumption.
                            + eapply TermSubst ; eassumption.
                          - { apply CongId.
                              - apply EqTyRefl.
                                eapply TySubst.
                                + eapply SubstWeak.
                                  eapply TySubst ; eassumption.
                                + eapply TySubst ; eassumption.
                              - apply EqRefl.
                                eapply TermSubst.
                                + eapply SubstWeak.
                                  eapply TySubst ; eassumption.
                                + eapply TermSubst ; eassumption.
                              - destruct todo. (* This is false... *)
                            }
                        }
                    - destruct todo.
                  }
            }
          + apply @TermSubst with (D := D) ; assumption.
          + eapply TermTyConv.
            * eapply @TermSubst with (D := D) ; eassumption.
            * apply @EqTySubstId with (D := D) ; assumption.
        - (* This is more or less the same thing as needed for w.
             We need to figure out how to deal with these substitutions. *)
          destruct todo. (* Still no stength *)
      }

    (* EqSubstExfalso *)
    + eapply TySubst.
      * eassumption.
      * assumption.
    + eapply TermSubst.
      * eassumption.
      * apply TermExfalso ; assumption.
    + constructor ; try magic.
      * now apply @TySubst with (D := D).
      * { eapply TermTyConv.
          - apply @TermSubst with (D := D).
            + assumption.
            + eassumption.
          - now apply @EqTySubstEmpty with (D := D).
        }

    (* EqSubstUnit *)
    + eapply TermTyConv.
      * { apply @TermSubst with (D := D).
          - assumption.
          - apply TermUnit. ih.
        }
      * now apply @EqTySubstUnit with (D := D).

    (* EqSubstTrue *)
    + eapply TermTyConv.
      * { apply @TermSubst with (D := D).
          - assumption.
          - apply TermTrue. ih.
        }
      * now apply @EqTySubstBool with (D := D).

    (* EqSubstFalse *)
    + eapply TermTyConv.
      * { apply @TermSubst with (D := D).
          - assumption.
          - apply TermFalse. ih.
        }
      * now apply @EqTySubstBool with (D := D).

    (* EqSubstCond *)
    + { eapply TySubst.
        - eassumption.
        - apply @TySubst with (D := ctxextend D Bool).
          + now apply SubstZero.
          + assumption.
      }
    + eapply TermSubst.
      * eassumption.
      * now apply TermCond.
    + { eapply TermTyConv.
        - apply TermCond.
          + { eapply TermTyConv.
              - eapply TermSubst.
                + eassumption.
                + eassumption.
              - now apply @EqTySubstBool with (D := D).
            }
          + { eapply TyCtxConv.
              - eapply TySubst.
                + eapply SubstShift.
                  * eassumption.
                  * ih.
                + assumption.
              - apply EqCtxExtend.
                + magic.
                + now apply @EqTySubstBool with (D := D).
            }
          + { eapply TermTyConv.
              - eapply TermSubst.
                + eassumption.
                + eassumption.
              - eapply EqTyTrans.
                + eapply EqTySym. apply EqTyShiftZero.
                  * assumption.
                  * assumption.
                  * apply TermTrue. ih.
                + { apply EqTyCongZero.
                    - now apply @EqTySubstBool with (D := D).
                    - eapply EqTyConv.
                      + now apply @EqSubstTrue with (D := D).
                      + apply EqTySym. now apply @EqTySubstBool with (D := D).
                    - apply EqTyRefl. apply @TySubst with (D := ctxextend D Bool).
                      + apply SubstShift.
                        * assumption.
                        * ih.
                      + assumption.
                  }
            }
          + { eapply TermTyConv.
              - eapply TermSubst.
                + eassumption.
                + eassumption.
              - eapply EqTyTrans.
                + eapply EqTySym. apply EqTyShiftZero.
                  * assumption.
                  * assumption.
                  * apply TermFalse. ih.
                + { apply EqTyCongZero.
                    - now apply @EqTySubstBool with (D := D).
                    - eapply EqTyConv.
                      + now apply @EqSubstFalse with (D := D).
                      + apply EqTySym. now apply @EqTySubstBool with (D := D).
                    - apply EqTyRefl. apply @TySubst with (D := ctxextend D Bool).
                      + apply SubstShift.
                        * assumption.
                        * ih.
                      + assumption.
                  }
            }
        - apply EqTySym. eapply EqTyTrans.
          + eapply EqTySym. now apply EqTyShiftZero.
          + { apply EqTyCongZero.
              - now apply @EqTySubstBool with (D := D).
              - apply EqRefl. now apply @TermSubst with (D := D).
              - apply EqTyRefl. apply @TySubst with (D := ctxextend D Bool).
                + apply SubstShift.
                  * assumption.
                  * ih.
                + assumption.
            }
      }

    (* EqReflection *)
    + eapply TyIdInversion. magic.
    + apply @TyIdInversion with (u := u) (v := v). magic.
    + apply @TyIdInversion with (u := u) (v := v). magic.

    (* ProdBeta *)
    + { eapply TySubst.
        - now apply SubstZero.
        - now apply (sane_isterm _ B u). }
    + { eapply TermSubst.
        - now apply SubstZero.
        - assumption. }

    (* CongAbs *)
    + { eapply TermTyConv.
        - apply TermAbs.
          + ih.
          + { eapply TermCtxConv.
              - eapply TermTyConv.
                + ih.
                + assumption.
              - apply EqCtxExtend.
                + magic.
                + assumption.
            }
        - apply CongProd.
          + now apply EqTySym.
          + { eapply EqTyCtxConv.
              - now apply @EqTySym with (G := ctxextend G A1).
              - apply EqCtxExtend ; magic. } }

    (* CongApp *)
    + { eapply TySubst.
        - apply SubstZero.
          ih.
        - ih. }
    + { eapply TermTyConv.
        - apply TermApp.
          + { eapply TyCtxConv.
              - ih.
              - apply EqCtxExtend ; magic. }
          + { eapply TermTyConv.
              - ih.
              - now apply CongProd. }
          + { eapply TermTyConv.
              - ih.
              - assumption. }
        - apply EqTySym.
          now apply EqTyCongZero. }

    (* ConfRefl *)
    + { eapply TermTyConv.
        - apply TermRefl.
          { eapply TermTyConv.
            - ih.
            - assumption. }
        - apply EqTySym.
          now apply CongId. }

    (* CongJ *)
    + { eapply TySubst.
        - eapply SubstZero. magic.
        - { eapply TyCtxConv.
            - eapply TySubst.
              + eapply SubstShift.
                * eapply SubstZero. magic.
                * { apply TyId.
                    - eapply TySubst.
                      + eapply SubstWeak. magic.
                      + magic.
                    - eapply TermSubst.
                      + eapply SubstWeak. magic.
                      + magic.
                    - apply TermVarZero. magic.
                  }
              + magic.
            - { apply EqCtxExtend.
                { magic. }
                { eapply EqTyTrans.
                  - eapply EqTySubstId.
                    + eapply SubstZero. magic.
                    + eapply TySubst.
                      * eapply SubstWeak. magic.
                      * magic.
                    + eapply TermSubst.
                      * eapply SubstWeak. magic.
                      * magic.
                    + apply TermVarZero. magic.
                  - apply CongId.
                    + apply EqTyWeakZero ; magic.
                    + apply EqSubstWeakZero.
                      * { eapply TermTyConv.
                          - magic.
                          - apply EqTySym.
                            apply EqTyWeakZero ; magic.
                        }
                      * magic.
                    + { eapply EqTyConv.
                        - apply EqSubstZeroZero. magic.
                        - apply EqTySym.
                          apply EqTyWeakZero ; magic.
                      }
                }
              }
          }
      }
    + { eapply TermTyConv.
        - eapply TermJ.
          + magic.
          + eapply TermTyConv.
            * magic.
            * magic.
          + eapply TyCtxConv.
            * magic.
            * { apply EqCtxExtend.
                - apply EqCtxExtend.
                  + magic.
                  + magic.
                - { apply CongId.
                    - eapply CongTySubst.
                      + eapply CongSubstWeak.
                        * magic.
                        * magic.
                      + magic.
                    - eapply CongTermSubst.
                      + eapply CongSubstWeak.
                        * magic.
                        * magic.
                      + magic.
                    - apply EqRefl.
                      apply TermVarZero.
                      magic.
                  }
              }
          + eapply TermTyConv.
            * magic.
            * { apply EqTyCongZero.
                - magic.
                - magic.
                - (* Congruence for shift, maybe as a lemma *)
                  eapply CongTySubst.
                  + { eapply EqSubstCtxConv.
                      - eapply CongSubstShift.
                        + magic.
                        + eapply CongSubstZero.
                          * (* Maybe need to change *)
                            apply CtxRefl. magic.
                          * magic.
                          * magic.
                        + { apply CongId.
                            - eapply CongTySubst.
                              + eapply CongSubstWeak.
                                * apply CtxRefl. magic.
                                * magic.
                              + magic.
                            - eapply CongTermSubst.
                              + eapply CongSubstWeak.
                                * apply CtxRefl. magic.
                                * magic.
                              + magic.
                            - apply EqRefl.
                              apply TermVarZero. magic.
                          }
                      - apply EqCtxExtend.
                        + apply CtxRefl. magic.
                        + { eapply EqTyTrans.
                            - eapply EqTySubstId.
                              + eapply SubstZero. magic.
                              + eapply TySubst.
                                * eapply SubstWeak. magic.
                                * magic.
                              + eapply TermSubst.
                                * eapply SubstWeak. magic.
                                * magic.
                              + apply TermVarZero. magic.
                            - apply CongId.
                              + apply EqTyWeakZero.
                                * magic.
                                * magic.
                              + apply EqSubstWeakZero.
                                * { eapply TermTyConv.
                                    - magic.
                                    - apply EqTySym.
                                      apply EqTyWeakZero.
                                      + magic.
                                      + magic.
                                  }
                                * magic.
                              + eapply EqTyConv.
                                * apply EqSubstZeroZero.
                                  magic.
                                * apply EqTySym.
                                  apply EqTyWeakZero ; magic.
                          }
                      - eapply EqCtxExtend.
                        + eapply EqCtxExtend.
                          * apply CtxRefl. ih.
                          * eassumption.
                        + (* For now. *)
                          apply EqTyRefl.
                          { apply TyId.
                            - eapply TySubst.
                              + eapply SubstWeak. magic.
                              + magic.
                            - eapply TermSubst.
                              + eapply SubstWeak. magic.
                              + magic.
                            - apply TermVarZero. magic.
                          }
                    }
                  + { eapply EqTyCtxConv.
                      - eassumption.
                      - apply EqCtxExtend.
                        + apply EqCtxExtend.
                          * apply CtxRefl. ih.
                          * magic.
                        + apply EqTyRefl.
                          { apply TyId.
                            - eapply TySubst.
                              + eapply SubstWeak. magic.
                              + magic.
                            - eapply TermSubst.
                              + eapply SubstWeak. magic.
                              + magic.
                            - apply TermVarZero.
                              magic.
                          }
                    }
              }
          + eapply TermTyConv.
            * magic.
            * magic.
          + eapply TermTyConv.
            * magic.
            * magic.
        - { apply EqTySym. apply EqTyCongZero.
            - magic.
            - magic.
            - (* We might also need congruence for shift... *)
              destruct todo.
          }
      }
    + eapply TySubst.
      * eapply SubstZero. magic.
      * magic.

    (* CongCond *)
    + { eapply TermTyConv.
        - { apply TermCond.
            - ih.
            - ih.
            - eapply TermTyConv.
              + ih.
              + apply @CongTySubst with (D := ctxextend G Bool).
                * { eapply CongSubstZero.
                    - apply CtxRefl.
                      magic.
                    - apply EqTyRefl. apply TyBool. magic.
                    - apply EqRefl. apply TermTrue. ih.
                  }
                * assumption.
            - eapply TermTyConv.
              + ih.
              + apply @CongTySubst with (D := ctxextend G Bool).
                * { eapply CongSubstZero.
                    - apply CtxRefl.
                      magic.
                    - apply EqTyRefl. apply TyBool. magic.
                    - apply EqRefl. apply TermFalse. ih.
                  }
                * assumption.
          }
        - apply EqTySym. eapply EqTyTrans.
          + eapply CongTySubst.
            * { eapply CongSubstZero.
                - apply CtxRefl. magic.
                - apply EqTyRefl. magic.
                - eassumption.
              }
            * eassumption.
          + apply EqTyRefl.
            eapply TySubst.
            * eapply SubstZero.
              ih.
            * ih.
      }

    (* CongTermSubst *)
    + apply @TySubst with (D := D).
      * ih.
      * ih.
    + apply @TermSubst with (D := D).
      * ih.
      * ih.
    + { eapply TermTyConv.
        - eapply TermSubst.
          + magic.
          + magic.
        - eapply CongTySubst.
          + eapply SubstSym. eassumption.
          + apply EqTyRefl. magic.
      }

Defined.