/*
 * gauche_l10n_japan_era.c
 */

#include "gauche_l10n_japan_era.h"

/*
 * The following function is a dummy one; replace it for
 * your C function definitions.
 */

ScmObj test_gauche_l10n_japan_era(void)
{
    return SCM_MAKE_STR("gauche_l10n_japan_era is working");
}

/*
 * Module initialization function.
 */
extern void Scm_Init_gauche_l10n_japan_eralib(ScmModule*);

void Scm_Init_gauche_l10n_japan_era(void)
{
    ScmModule *mod;

    /* Register this DSO to Gauche */
    SCM_INIT_EXTENSION(gauche_l10n_japan_era);

    /* Create the module if it doesn't exist yet. */
    mod = SCM_MODULE(SCM_FIND_MODULE("gauche_l10n_japan_era", TRUE));

    /* Register stub-generated procedures */
    Scm_Init_gauche_l10n_japan_eralib(mod);
}
