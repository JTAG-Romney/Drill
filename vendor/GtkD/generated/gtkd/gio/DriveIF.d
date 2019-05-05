/*
 * This file is part of gtkD.
 *
 * gtkD is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version, with
 * some exceptions, please read the COPYING file.
 *
 * gtkD is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with gtkD; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA
 */

// generated automatically - do not change
// find conversion definition on APILookup.txt
// implement new conversion functionalities on the wrap.utils pakage


module gio.DriveIF;

private import gio.AsyncResultIF;
private import gio.Cancellable;
private import gio.IconIF;
private import gio.MountOperation;
private import gio.c.functions;
public  import gio.c.types;
private import glib.ErrorG;
private import glib.GException;
private import glib.ListG;
private import glib.Str;
private import gobject.ObjectG;
private import gobject.Signals;
public  import gtkc.giotypes;
private import std.algorithm;


/**
 * #GDrive - this represent a piece of hardware connected to the machine.
 * It's generally only created for removable hardware or hardware with
 * removable media.
 * 
 * #GDrive is a container class for #GVolume objects that stem from
 * the same piece of media. As such, #GDrive abstracts a drive with
 * (or without) removable media and provides operations for querying
 * whether media is available, determining whether media change is
 * automatically detected and ejecting the media.
 * 
 * If the #GDrive reports that media isn't automatically detected, one
 * can poll for media; typically one should not do this periodically
 * as a poll for media operation is potententially expensive and may
 * spin up the drive creating noise.
 * 
 * #GDrive supports starting and stopping drives with authentication
 * support for the former. This can be used to support a diverse set
 * of use cases including connecting/disconnecting iSCSI devices,
 * powering down external disk enclosures and starting/stopping
 * multi-disk devices such as RAID devices. Note that the actual
 * semantics and side-effects of starting/stopping a #GDrive may vary
 * according to implementation. To choose the correct verbs in e.g. a
 * file manager, use g_drive_get_start_stop_type().
 * 
 * For porting from GnomeVFS note that there is no equivalent of
 * #GDrive in that API.
 */
public interface DriveIF{
	/** Get the main Gtk struct */
	public GDrive* getDriveStruct(bool transferOwnership = false);

	/** the main Gtk struct as a void* */
	protected void* getStruct();


	/** */
	public static GType getType()
	{
		return g_drive_get_type();
	}

	/**
	 * Checks if a drive can be ejected.
	 *
	 * Returns: %TRUE if the @drive can be ejected, %FALSE otherwise.
	 */
	public bool canEject();

	/**
	 * Checks if a drive can be polled for media changes.
	 *
	 * Returns: %TRUE if the @drive can be polled for media changes,
	 *     %FALSE otherwise.
	 */
	public bool canPollForMedia();

	/**
	 * Checks if a drive can be started.
	 *
	 * Returns: %TRUE if the @drive can be started, %FALSE otherwise.
	 *
	 * Since: 2.22
	 */
	public bool canStart();

	/**
	 * Checks if a drive can be started degraded.
	 *
	 * Returns: %TRUE if the @drive can be started degraded, %FALSE otherwise.
	 *
	 * Since: 2.22
	 */
	public bool canStartDegraded();

	/**
	 * Checks if a drive can be stopped.
	 *
	 * Returns: %TRUE if the @drive can be stopped, %FALSE otherwise.
	 *
	 * Since: 2.22
	 */
	public bool canStop();

	/**
	 * Asynchronously ejects a drive.
	 *
	 * When the operation is finished, @callback will be called.
	 * You can then call g_drive_eject_finish() to obtain the
	 * result of the operation.
	 *
	 * Deprecated: Use g_drive_eject_with_operation() instead.
	 *
	 * Params:
	 *     flags = flags affecting the unmount if required for eject
	 *     cancellable = optional #GCancellable object, %NULL to ignore.
	 *     callback = a #GAsyncReadyCallback, or %NULL.
	 *     userData = user data to pass to @callback
	 */
	public void eject(GMountUnmountFlags flags, Cancellable cancellable, GAsyncReadyCallback callback, void* userData);

	/**
	 * Finishes ejecting a drive.
	 *
	 * Deprecated: Use g_drive_eject_with_operation_finish() instead.
	 *
	 * Params:
	 *     result = a #GAsyncResult.
	 *
	 * Returns: %TRUE if the drive has been ejected successfully,
	 *     %FALSE otherwise.
	 *
	 * Throws: GException on failure.
	 */
	public bool ejectFinish(AsyncResultIF result);

	/**
	 * Ejects a drive. This is an asynchronous operation, and is
	 * finished by calling g_drive_eject_with_operation_finish() with the @drive
	 * and #GAsyncResult data returned in the @callback.
	 *
	 * Params:
	 *     flags = flags affecting the unmount if required for eject
	 *     mountOperation = a #GMountOperation or %NULL to avoid
	 *         user interaction.
	 *     cancellable = optional #GCancellable object, %NULL to ignore.
	 *     callback = a #GAsyncReadyCallback, or %NULL.
	 *     userData = user data passed to @callback.
	 *
	 * Since: 2.22
	 */
	public void ejectWithOperation(GMountUnmountFlags flags, MountOperation mountOperation, Cancellable cancellable, GAsyncReadyCallback callback, void* userData);

	/**
	 * Finishes ejecting a drive. If any errors occurred during the operation,
	 * @error will be set to contain the errors and %FALSE will be returned.
	 *
	 * Params:
	 *     result = a #GAsyncResult.
	 *
	 * Returns: %TRUE if the drive was successfully ejected. %FALSE otherwise.
	 *
	 * Since: 2.22
	 *
	 * Throws: GException on failure.
	 */
	public bool ejectWithOperationFinish(AsyncResultIF result);

	/**
	 * Gets the kinds of identifiers that @drive has.
	 * Use g_drive_get_identifier() to obtain the identifiers
	 * themselves.
	 *
	 * Returns: a %NULL-terminated
	 *     array of strings containing kinds of identifiers. Use g_strfreev()
	 *     to free.
	 */
	public string[] enumerateIdentifiers();

	/**
	 * Gets the icon for @drive.
	 *
	 * Returns: #GIcon for the @drive.
	 *     Free the returned object with g_object_unref().
	 */
	public IconIF getIcon();

	/**
	 * Gets the identifier of the given kind for @drive.
	 *
	 * Params:
	 *     kind = the kind of identifier to return
	 *
	 * Returns: a newly allocated string containing the
	 *     requested identfier, or %NULL if the #GDrive
	 *     doesn't have this kind of identifier.
	 */
	public string getIdentifier(string kind);

	/**
	 * Gets the name of @drive.
	 *
	 * Returns: a string containing @drive's name. The returned
	 *     string should be freed when no longer needed.
	 */
	public string getName();

	/**
	 * Gets the sort key for @drive, if any.
	 *
	 * Returns: Sorting key for @drive or %NULL if no such key is available.
	 *
	 * Since: 2.32
	 */
	public string getSortKey();

	/**
	 * Gets a hint about how a drive can be started/stopped.
	 *
	 * Returns: A value from the #GDriveStartStopType enumeration.
	 *
	 * Since: 2.22
	 */
	public GDriveStartStopType getStartStopType();

	/**
	 * Gets the icon for @drive.
	 *
	 * Returns: symbolic #GIcon for the @drive.
	 *     Free the returned object with g_object_unref().
	 *
	 * Since: 2.34
	 */
	public IconIF getSymbolicIcon();

	/**
	 * Get a list of mountable volumes for @drive.
	 *
	 * The returned list should be freed with g_list_free(), after
	 * its elements have been unreffed with g_object_unref().
	 *
	 * Returns: #GList containing any #GVolume objects on the given @drive.
	 */
	public ListG getVolumes();

	/**
	 * Checks if the @drive has media. Note that the OS may not be polling
	 * the drive for media changes; see g_drive_is_media_check_automatic()
	 * for more details.
	 *
	 * Returns: %TRUE if @drive has media, %FALSE otherwise.
	 */
	public bool hasMedia();

	/**
	 * Check if @drive has any mountable volumes.
	 *
	 * Returns: %TRUE if the @drive contains volumes, %FALSE otherwise.
	 */
	public bool hasVolumes();

	/**
	 * Checks if @drive is capabable of automatically detecting media changes.
	 *
	 * Returns: %TRUE if the @drive is capabable of automatically detecting
	 *     media changes, %FALSE otherwise.
	 */
	public bool isMediaCheckAutomatic();

	/**
	 * Checks if the @drive supports removable media.
	 *
	 * Returns: %TRUE if @drive supports removable media, %FALSE otherwise.
	 */
	public bool isMediaRemovable();

	/**
	 * Checks if the #GDrive and/or its media is considered removable by the user.
	 * See g_drive_is_media_removable().
	 *
	 * Returns: %TRUE if @drive and/or its media is considered removable, %FALSE otherwise.
	 *
	 * Since: 2.50
	 */
	public bool isRemovable();

	/**
	 * Asynchronously polls @drive to see if media has been inserted or removed.
	 *
	 * When the operation is finished, @callback will be called.
	 * You can then call g_drive_poll_for_media_finish() to obtain the
	 * result of the operation.
	 *
	 * Params:
	 *     cancellable = optional #GCancellable object, %NULL to ignore.
	 *     callback = a #GAsyncReadyCallback, or %NULL.
	 *     userData = user data to pass to @callback
	 */
	public void pollForMedia(Cancellable cancellable, GAsyncReadyCallback callback, void* userData);

	/**
	 * Finishes an operation started with g_drive_poll_for_media() on a drive.
	 *
	 * Params:
	 *     result = a #GAsyncResult.
	 *
	 * Returns: %TRUE if the drive has been poll_for_mediaed successfully,
	 *     %FALSE otherwise.
	 *
	 * Throws: GException on failure.
	 */
	public bool pollForMediaFinish(AsyncResultIF result);

	/**
	 * Asynchronously starts a drive.
	 *
	 * When the operation is finished, @callback will be called.
	 * You can then call g_drive_start_finish() to obtain the
	 * result of the operation.
	 *
	 * Params:
	 *     flags = flags affecting the start operation.
	 *     mountOperation = a #GMountOperation or %NULL to avoid
	 *         user interaction.
	 *     cancellable = optional #GCancellable object, %NULL to ignore.
	 *     callback = a #GAsyncReadyCallback, or %NULL.
	 *     userData = user data to pass to @callback
	 *
	 * Since: 2.22
	 */
	public void start(GDriveStartFlags flags, MountOperation mountOperation, Cancellable cancellable, GAsyncReadyCallback callback, void* userData);

	/**
	 * Finishes starting a drive.
	 *
	 * Params:
	 *     result = a #GAsyncResult.
	 *
	 * Returns: %TRUE if the drive has been started successfully,
	 *     %FALSE otherwise.
	 *
	 * Since: 2.22
	 *
	 * Throws: GException on failure.
	 */
	public bool startFinish(AsyncResultIF result);

	/**
	 * Asynchronously stops a drive.
	 *
	 * When the operation is finished, @callback will be called.
	 * You can then call g_drive_stop_finish() to obtain the
	 * result of the operation.
	 *
	 * Params:
	 *     flags = flags affecting the unmount if required for stopping.
	 *     mountOperation = a #GMountOperation or %NULL to avoid
	 *         user interaction.
	 *     cancellable = optional #GCancellable object, %NULL to ignore.
	 *     callback = a #GAsyncReadyCallback, or %NULL.
	 *     userData = user data to pass to @callback
	 *
	 * Since: 2.22
	 */
	public void stop(GMountUnmountFlags flags, MountOperation mountOperation, Cancellable cancellable, GAsyncReadyCallback callback, void* userData);

	/**
	 * Finishes stopping a drive.
	 *
	 * Params:
	 *     result = a #GAsyncResult.
	 *
	 * Returns: %TRUE if the drive has been stopped successfully,
	 *     %FALSE otherwise.
	 *
	 * Since: 2.22
	 *
	 * Throws: GException on failure.
	 */
	public bool stopFinish(AsyncResultIF result);

	/**
	 * Emitted when the drive's state has changed.
	 */
	gulong addOnChanged(void delegate(DriveIF) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0);

	/**
	 * This signal is emitted when the #GDrive have been
	 * disconnected. If the recipient is holding references to the
	 * object they should release them so the object can be
	 * finalized.
	 */
	gulong addOnDisconnected(void delegate(DriveIF) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0);

	/**
	 * Emitted when the physical eject button (if any) of a drive has
	 * been pressed.
	 */
	gulong addOnEjectButton(void delegate(DriveIF) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0);

	/**
	 * Emitted when the physical stop button (if any) of a drive has
	 * been pressed.
	 *
	 * Since: 2.22
	 */
	gulong addOnStopButton(void delegate(DriveIF) dlg, ConnectFlags connectFlags=cast(ConnectFlags)0);
}
