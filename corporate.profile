<?php

/**
 * @file
 * Enables modules and site configuration for the Corporate profile.
 */

use Drupal\Core\Form\FormStateInterface;

function corporate_form_install_configure_form_alter(&$form, FormStateInterface $form_state) {
  // When using Drush, let it set the default password.
  if (PHP_SAPI === 'cli') {
    return;
  }

  // Site information.
  $form['site_information']['site_name']['#default_value'] = 'Default Corporate Site';
  $form['site_information']['site_mail']['#default_value'] = 'admin@smartidea.com.ua';

  // Account information.
  $form['admin_account']['account']['name']['#default_value'] = 'admin';
  $form['admin_account']['account']['mail']['#default_value'] = 'admin@smartidea.com.ua';

  // Set the default admin password.
  $form['admin_account']['account']['pass']['#value'] = 'admin';
  $form['admin_account']['account']['pass']['#required'] = FALSE;

  // Add informations about the default username and password.
  $form['admin_account']['account']['corporate_name'] = array(
    '#type' => 'item',
    '#title' => t('Username'),
    '#markup' => 'admin'
  );

  $form['admin_account']['account']['corporate_password'] = array(
    '#type' => 'item',
    '#title' => t('Password'),
    '#markup' => 'admin'
  );

  $form['admin_account']['override_account_informations'] = array(
    '#type' => 'checkbox',
    '#title' => t('Change my username and password.'),
  );

  $form['admin_account']['setup_account'] = array(
    '#type' => 'container',
    '#parents' => array('admin_account'),
    '#states' => array(
      'invisible' => array(
        'input[name="override_account_informations"]' => array('checked' => FALSE),
      ),
    ),
  );

  // Make a "copy" of the original name and pass form fields.
  $form['admin_account']['setup_account']['account']['name'] = $form['admin_account']['account']['name'];
  $form['admin_account']['setup_account']['account']['pass'] = $form['admin_account']['account']['pass'];
  $form['admin_account']['setup_account']['account']['pass']['#value'] = array('pass1' => 'admin', 'pass2' => 'admin');

  // Use "admin" as the default username.
  $form['admin_account']['account']['name']['#access'] = FALSE;

  // Make the password "hidden".
  $form['admin_account']['account']['pass']['#type'] = 'hidden';
  $form['admin_account']['account']['mail']['#access'] = FALSE;

  // Date/time settings.
  $form['regional_settings']['site_default_country']['#default_value'] = 'UA';
  $form['regional_settings']['date_default_timezone']['#default_value'] = 'Europe/Kiev';

  // Disable e-mail notifications.
  $form["update_notifications"]['update_status_module']['#default_value'] = [1, 0];

  // Add a custom validation that needs to be trigger before the original one,
  // where we can copy the site's mail as the admin account's mail.
  array_unshift($form['#validate'], 'corporate_custom_setting');
}

/**
 * Validate callback; Populate the admin account mail, user and password with
 * custom values.
 */
function corporate_custom_setting(&$form, $form_state) {
  $form_state->setValue(['account', 'mail'], $form_state->getValue('site_mail'));
  // Use our custom values only the corresponding checkbox is checked.
  if ($form_state->getValue('override_account_informations') == TRUE) {
  	if ((!empty($form_state->getUserInput()['pass']['pass1']) && !empty($form_state->getUserInput()['pass']['pass2'])) && 
  	   ($form_state->getUserInput()['pass']['pass1'] == $form_state->getUserInput()['pass']['pass2'])) {
        $form_state->setValue(['account', 'name'], $form_state->getValue('name'));
        $form_state->setValue(['account', 'pass'], $form_state->getUserInput()['pass']['pass1']);
    }
    else {
      $form_state->setErrorByName(
        'pass',
        t("The specified passwords do not match.")
      );
    }
  }
}
